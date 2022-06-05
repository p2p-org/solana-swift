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
    
    func nativeAccountNotification(notification: SocketNativeAccountNotification) {}
    
    func tokenAccountNotification(notification: SocketTokenAccountNotification) {}
    
    func programNotification(notification: SocketProgramAccountNotification) {}
    
    func signatureNotification(notification: SocketSignatureNotification) {}
    
    func logsNotification(notification: SocketLogsNotification) {}
    
    func unsubscribed(id: String) {}
    
    func subscribed(socketId: UInt64, id: String) {}
    
    func disconnected(reason: String, code: Int) {}
    
    func error(error: Error?) {}
}