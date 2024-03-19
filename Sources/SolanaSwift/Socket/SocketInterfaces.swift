import Foundation

/// The abstract websocket task provider, default is URLSession
public protocol WebSocketTaskProvider {
    init(configuration: URLSessionConfiguration, delegate: URLSessionDelegate?, delegateQueue queue: OperationQueue?)
    func createWebSocketTask(with url: URL) -> WebSocketTask
}

extension URLSession: WebSocketTaskProvider {
    public func createWebSocketTask(with url: URL) -> WebSocketTask {
        webSocketTask(with: url)
    }
}

/// Abstract websocket task, default is URLSessionWebSocketTask
public protocol WebSocketTask {
    func resume()
    func cancel()
    func send(_ message: URLSessionWebSocketTask.Message) async throws
    func receive() async throws -> URLSessionWebSocketTask.Message
    func sendPing(pongReceiveHandler: @escaping (Error?) -> Void)
}

extension URLSessionWebSocketTask: WebSocketTask {}

/// Delegate for listening socket's events
public protocol SolanaSocketEventsDelegate: AnyObject {
    func connected()
    func nativeAccountNotification(notification: SocketNativeAccountNotification)
    func tokenAccountNotification(notification: SocketTokenAccountNotification)
    func programNotification(notification: SocketProgramAccountNotification)
    func signatureNotification(notification: SocketSignatureNotification)
    func logsNotification(notification: SocketLogsNotification)
    func unsubscribed(id: String)
    func subscribed(socketId: UInt64, id: String)
    func disconnected(reason: String, code: Int)
    func error(error: Error?)
}

public extension SolanaSocketEventsDelegate {
    func connected() {}

    func nativeAccountNotification(notification _: SocketNativeAccountNotification) {}

    func tokenAccountNotification(notification _: SocketTokenAccountNotification) {}

    func programNotification(notification _: SocketProgramAccountNotification) {}

    func signatureNotification(notification _: SocketSignatureNotification) {}

    func logsNotification(notification _: SocketLogsNotification) {}

    func unsubscribed(id _: String) {}

    func subscribed(socketId _: UInt64, id _: String) {}

    func disconnected(reason _: String, code _: Int) {}

    func error(error _: Error?) {}
}
