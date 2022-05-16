import Foundation

public protocol WebSocketTaskProvider {
    init(configuration: URLSessionConfiguration, delegate: URLSessionDelegate?, delegateQueue queue: OperationQueue?)
    func createWebSocketTask(with url: URL) -> WebSocketTask
}

extension URLSession: WebSocketTaskProvider {
    public func createWebSocketTask(with url: URL) -> WebSocketTask {
        webSocketTask(with: url)
    }
}

public protocol WebSocketTask {
    func resume()
    func cancel()
    func send(_ message: URLSessionWebSocketTask.Message) async throws
    func receive() async throws -> URLSessionWebSocketTask.Message
    func sendPing(pongReceiveHandler: @escaping (Error?) -> Void)
}

extension URLSessionWebSocketTask: WebSocketTask {}
