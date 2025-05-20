public protocol FileScanning {
    func scan(url: URL) -> AsyncStream<FileMeta>
}

public struct FileMeta {
    public let url: URL
}
