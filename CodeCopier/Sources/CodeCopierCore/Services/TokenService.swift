import Foundation
import Combine
import Tiktoken

/// Actor responsible for batching tokenization requests using `Tiktoken`.
/// Progress updates are published via `progressPublisher` so callers can
/// report status while large sources are processed.
public actor TokenService {
    public enum ServiceError: Error {
        case tokenizationFailed
    }

    private let tokenizer: Tiktoken
    private let progressSubject = PassthroughSubject<Double, Never>()

    /// Publisher emitting progress in the range `0.0...1.0`.
    public var progressPublisher: AnyPublisher<Double, Never> {
        progressSubject.eraseToAnyPublisher()
    }

    /// Creates a new service for the given model.
    public init(model: Model = .gpt35) throws {
        self.tokenizer = try Tiktoken(model: model)
    }

    /// Returns the token count for the provided text.
    public func tokenCount(for text: String) async throws -> Int {
        try await tokenize(text).count
    }

    /// Tokenizes the text in parallel batches and reports progress.
    /// - Parameters:
    ///   - text: Source text to tokenize.
    ///   - batchSize: Approximate character batch size for parallel work.
    public func tokenize(_ text: String, batchSize: Int = 8192) async throws -> [Int] {
        let utf8 = Array(text.utf8)
        let total = utf8.count
        guard total > 0 else { return [] }

        let chunkCount = (total + batchSize - 1) / batchSize
        var results = Array(repeating: [Int](), count: chunkCount)

        try await withThrowingTaskGroup(of: (Int, [Int]).self) { group in
            for index in 0..<chunkCount {
                let start = index * batchSize
                let end = min(start + batchSize, total)
                let slice = utf8[start..<end]
                group.addTask {
                    let textChunk = String(decoding: slice, as: UTF8.self)
                    let tokens = try self.tokenizer.encode(textChunk)
                    return (index, tokens)
                }
            }

            var completed = 0
            for try await (index, tokens) in group {
                results[index] = tokens
                completed += 1
                progressSubject.send(Double(completed) / Double(chunkCount))
            }
        }

        progressSubject.send(completion: .finished)
        return results.flatMap { $0 }
    }
}
