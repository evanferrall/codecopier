public protocol SourceAggregator {
    func aggregate(_ files: [FileInfo], split: Int, includeTOC: Bool) async throws -> [String]
}

public struct FileInfo {
    public let path: String
}
