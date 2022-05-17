import Foundation
import LoggerSwift

public protocol SolanaSocket {
    /// Connection status of the socket
    var isConnected: Bool {get}
    
    /// Delegation
    var delegate: SolanaSocketEventsDelegate? {get set}
    
    /// Connect to socket
    func connect()
    
    /// Disconnect from socket
    func disconnect()
    
    /// Subscribe to `accountNotification`
    /// - Parameter publickey: account to be subscribed
    /// - Returns: id of the request
    @discardableResult func accountSubscribe(publickey: String) async throws -> String
    
    /// Unsubscribe from `accountNotification`
    /// - Parameter socketId: id of the subscription
    /// - Returns: id of the request
    @discardableResult func accountUnsubscribe(socketId: UInt64) async throws -> String
    
    /// Subscribe to `signatureNotification`
    /// - Parameter signature: signature to be subscribed
    /// - Returns: id of the request
    @discardableResult func signatureSubscribe(signature: String) async throws -> String
    
    /// Unsubscribe to `signatureNotification`
    /// - Parameter socketId: id of the subscription
    /// - Returns: id of the request
    @discardableResult func signatureUnsubscribe(socketId: UInt64) async throws -> String
    
    /// Subscribe to `logsNotification`
    /// - Parameter mentions: accounts to be subscribed
    /// - Returns: id of the request
    @discardableResult func logsSubscribe(mentions: [String]) async throws -> String
    
    /// Subscribe to all events
    /// - Returns: id of the request
    @discardableResult func logsSubscribeAll() async throws -> String
    
    /// Unsubscribe to `logsNotification`
    /// - Parameter socketId: id of the subscription
    /// - Returns: id of the request
    @discardableResult func logsUnsubscribe(socketId: UInt64) async throws -> String
    
    /// Subscribe to `programNotification`
    /// - Parameter publickey: program to be subscribed
    /// - Returns: id of the request
    @discardableResult func programSubscribe(publickey: String) async throws -> String
    
    /// Unsubscribe to `programNotification`
    /// - Parameter socketId: id of the subscription
    /// - Returns: id of the request
    @discardableResult func programUnsubscribe(socketId: UInt64) async throws -> String
}

public class Socket: NSObject, SolanaSocket {
    // MARK: - Properties
    /// Connection status of the socket
    public var isConnected: Bool = false
    
    /// Socket task to handle socket event
    private var task: WebSocketTask!
    
    /// Enable/disable logging
    private let enableDebugLogs: Bool
    
    /// Timer to send pings to prevent idie time out
    private var wsHeartBeat: Timer!
    
    /// Async task to keep track of asynchronous receiving task
    private var asyncTask: Task<Void, Error>?
    
    /// Delegation
    public weak var delegate: SolanaSocketEventsDelegate?
    
    // MARK: - Initializers
    /// Initializer for Socket
    /// - Parameters:
    ///   - url: url of the socket
    ///   - enableDebugLogs: enable/disable logging
    ///   - socketTaskProviderType: type of task provider, default is `URLSession.self`
    public init<T: WebSocketTaskProvider>(
        url: URL,
        enableDebugLogs: Bool,
        socketTaskProviderType: T.Type
    ) {
        self.enableDebugLogs = enableDebugLogs
        super.init()
        let urlSession = T(configuration: .default, delegate: self, delegateQueue: .current!)
        self.task = urlSession.createWebSocketTask(with: url)
    }
    
    /// Convenience initializer for socket using `URLSession` as `WebSocketTaskProvider`
    /// - Parameters:
    ///   - url: url of the socket
    ///   - enableDebugLogs: enable/disable logging
    public convenience init(
        url: URL,
        enableDebugLogs: Bool
    ) {
        self.init(url: url, enableDebugLogs: enableDebugLogs, socketTaskProviderType: URLSession.self)
    }
    
    deinit {
        disconnect()
    }
    
    // MARK: - Methods
    /// Connect to socket
    public func connect() {
        task.resume()
    }
    
    /// Disconnect from socket
    public func disconnect() {
        delegate?.disconnected(reason: "", code: 0)
        
        asyncTask?.cancel()
        task.cancel()
        delegate = nil
        wsHeartBeat?.invalidate()
        wsHeartBeat = nil
    }
    
    /// Subscribe to `accountNotification`
    /// - Parameter publickey: account to be subscribed
    /// - Returns: id of the request
    @discardableResult public func accountSubscribe(publickey: String) async throws -> String {
        let method: SocketMethod = .init(.account, .subscribe)
        let params: [Encodable] = [ publickey, ["commitment": "recent", "encoding": "base64"] ]
        let request = RequestAPI(method: method.rawValue, params: params)
        return try await writeToSocket(request: request)
    }
    
    /// Unsubscribe from `accountNotification`
    /// - Parameter socketId: id of the subscription
    /// - Returns: id of the request
    @discardableResult public func accountUnsubscribe(socketId: UInt64) async throws -> String {
        let method: SocketMethod = .init(.account, .unsubscribe)
        let params: [Encodable] = [socketId]
        let request = RequestAPI(method: method.rawValue, params: params)
        return try await writeToSocket(request: request)
    }
    
    /// Subscribe to `signatureNotification`
    /// - Parameter signature: signature to be subscribed
    /// - Returns: id of the request
    @discardableResult public func signatureSubscribe(signature: String) async throws -> String {
        let method: SocketMethod = .init(.signature, .subscribe)
        let params: [Encodable] = [signature, ["commitment": "confirmed", "encoding": "base64"]]
        let request = RequestAPI(method: method.rawValue, params: params)
        return try await writeToSocket(request: request)
    }
    
    /// Unsubscribe to `signatureNotification`
    /// - Parameter socketId: id of the subscription
    /// - Returns: id of the request
    @discardableResult public func signatureUnsubscribe(socketId: UInt64) async throws -> String {
        let method: SocketMethod = .init(.signature, .unsubscribe)
        let params: [Encodable] = [socketId]
        let request = RequestAPI(method: method.rawValue, params: params)
        return try await writeToSocket(request: request)
    }
    
    /// Subscribe to `logsNotification`
    /// - Parameter mentions: accounts to be subscribed
    /// - Returns: id of the request
    @discardableResult public func logsSubscribe(mentions: [String]) async throws -> String {
        let method: SocketMethod = .init(.logs, .subscribe)
        let params: [Encodable] = [["mentions": mentions], ["commitment": "confirmed", "encoding": "base64"]]
        let request = RequestAPI(method: method.rawValue, params: params)
        return try await writeToSocket(request: request)
    }
    
    /// Subscribe to all events
    /// - Returns: id of the request
    @discardableResult public func logsSubscribeAll() async throws -> String {
        let method: SocketMethod = .init(.logs, .subscribe)
        let params: [Encodable] = ["all", ["commitment": "confirmed", "encoding": "base64"]]
        let request = RequestAPI(method: method.rawValue, params: params)
        return try await writeToSocket(request: request)
    }
    
    /// Unsubscribe to `logsNotification`
    /// - Parameter socketId: id of the subscription
    /// - Returns: id of the request
    @discardableResult public func logsUnsubscribe(socketId: UInt64) async throws -> String {
        let method: SocketMethod = .init(.logs, .unsubscribe)
        let params: [Encodable] = [socketId]
        let request = RequestAPI(method: method.rawValue, params: params)
        return try await writeToSocket(request: request)
    }
    
    /// Subscribe to `programNotification`
    /// - Parameter publickey: program to be subscribed
    /// - Returns: id of the request
    @discardableResult public func programSubscribe(publickey: String) async throws -> String {
        let method: SocketMethod = .init(.program, .subscribe)
        let params: [Encodable] = [publickey, ["commitment": "confirmed", "encoding": "base64"]]
        let request = RequestAPI(method: method.rawValue, params: params)
        return try await writeToSocket(request: request)
    }
    
    /// Unsubscribe to `programNotification`
    /// - Parameter socketId: id of the subscription
    /// - Returns: id of the request
    @discardableResult public func programUnsubscribe(socketId: UInt64) async throws -> String {
        let method: SocketMethod = .init(.program, .unsubscribe)
        let params: [Encodable] = [socketId]
        let request = RequestAPI(method: method.rawValue, params: params)
        return try await writeToSocket(request: request)
    }
    
    /// Emit message to socket
    /// - Parameter request: request to be sent
    /// - Returns: request id
    @discardableResult private func writeToSocket(request: RequestAPI) async throws -> String {
        guard let jsonData = try? JSONEncoder().encode(request) else {
            throw SocketError.couldNotSerialize
        }
        if enableDebugLogs {
            Logger.log(event: .request, message: "\(String(data: jsonData, encoding: .utf8) ?? "")")
        }
        try await task.send(.data(jsonData))
        return request.id
    }
    
    /// Read message from socket one at a time
    private func readMessage() async throws {
        try Task.checkCancellation()
        let message = try await task.receive()
        switch message {
        case .string(let text):
            if enableDebugLogs {
                Logger.log(event: .event, message: "Receive string from socket: \(text)")
            }
            guard let data = text.data(using: .utf8) else { return }
            do {
                // TODO: Fix this mess code
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                if let jsonType = jsonResponse["method"] as? String,
                   let type = SocketMethod(rawValue: jsonType),
                   type.action == .notification
                {
                    switch type.entity {
                    case .account:
                        if let notification = try? JSONDecoder().decode(SocketNativeAccountNotification.self, from: data)
                        {
                            delegate?.nativeAccountNotification(notification: notification)
                        } else {
                            let notification = try JSONDecoder().decode(SocketTokenAccountNotification.self, from: data)
                            delegate?.tokenAccountNotification(notification: notification)
                        }
                        
                    case .signature:
                        let notification = try JSONDecoder().decode(SocketSignatureNotification.self, from: data)
                        delegate?.signatureNotification(notification: notification)
                    case .logs:
                        let notification = try JSONDecoder().decode(SocketLogsNotification.self, from: data)
                        delegate?.logsNotification(notification: notification)
                    case .program:
                        let notification = try JSONDecoder().decode(SocketProgramAccountNotification.self, from: data)
                        delegate?.programNotification(notification: notification)
                    default:
                        break
                    }
                    
                } else {
                    if let subscription = try? JSONDecoder().decode(SocketSubscriptionResponse.self, from: data),
                       let socketId = subscription.result,
                       let id = subscription.id {
                        delegate?.subscribed(socketId: socketId, id: id)
                    }
                    
                    if let subscription = try? JSONDecoder().decode(SocketUnsubscriptionResponse.self, from: data),
                       subscription.result == true,
                       let id = subscription.id {
                        delegate?.unsubscribed(id: id)
                    }
                }
            } catch let error {
                delegate?.error(error: error)
            }
            try await self.readMessage()
        case .data(let data):
            print("Received binary message: \(data)")
        @unknown default:
            fatalError()
        }
    }
    
    private func ping() {
        task.sendPing { (error) in
            if let error = error {
                print("Ping failed: \(error)")
            }
        }
    }
}

extension Socket: URLSessionWebSocketDelegate {
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        isConnected = true
        wsHeartBeat?.invalidate()
        wsHeartBeat = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] (_) in
            // Ping server every 5s to prevent idle timeouts
            self?.ping()
        }
        delegate?.connected()
        
        if enableDebugLogs {
            Logger.log(event: .event, message: "Socket connected")
        }
        
        asyncTask = Task { [weak self] in
            try await self?.readMessage()
        }
    }
    
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        isConnected = false
        wsHeartBeat?.invalidate()
        task.resume()
        delegate?.disconnected(reason: reason?.jsonString ?? "", code: closeCode.rawValue)
        
        if enableDebugLogs {
            Logger.log(event: .event, message: "Socket disconnected")
        }
        
        asyncTask?.cancel()
    }
}
