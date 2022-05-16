import Foundation

public protocol WebSocketTaskProvider {
    init(configuration: URLSessionConfiguration, delegate: URLSessionDelegate?, delegateQueue queue: OperationQueue?)
    func createWebSocketTask(with url: URL) -> URLSessionWebSocketTask
}

extension URLSession: WebSocketTaskProvider {
    public func createWebSocketTask(with url: URL) -> URLSessionWebSocketTask {
        webSocketTask(with: url)
    }
}
