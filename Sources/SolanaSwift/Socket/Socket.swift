import Foundation

public protocol SolanaSocket {
    /// Connection status of the socket
    var isConnected: Bool { get }

    /// Delegation
    var delegate: SolanaSocketEventsDelegate? { get set }

    /// Connect to socket
    func connect()

    /// Disconnect from socket
    func disconnect()

    /// Subscribe to an entity ('account', 'program', 'signature', for example)
    /// - Parameters:
    ///   - type: type of entity, '.account', '.program',...
    ///   - params: params to be sent
    /// - Returns: id of the request
    @discardableResult func subscribe<T: Encodable>(
        type: SocketEntity,
        params: T,
        commitment: String,
        encoding: String
    ) async throws
        -> String

    /// Unsubscribe to an entity ('account', 'program', 'signature', for example)
    /// - Parameters:
    ///   - type: type of entity, '.account', '.program',...
    ///   - socketId: id of the subscription
    /// - Returns: id of the request
    @discardableResult func unsubscribe(type: SocketEntity, socketId: UInt64) async throws -> String
}

public extension SolanaSocket {
    /// Subscribe to `accountNotification`
    /// - Parameter publickey: account to be subscribed
    /// - Returns: id of the request
    @discardableResult func accountSubscribe(publickey: String, commitment: String = "recent") async throws -> String {
        try await subscribe(type: .account, params: publickey, commitment: commitment, encoding: "jsonParsed")
    }

    /// Subscribe to `signatureNotification`
    /// - Parameter signature: signature to be subscribed
    /// - Returns: id of the request
    @discardableResult func signatureSubscribe(signature: String,
                                               commitment: String = "confirmed") async throws -> String
    {
        try await subscribe(type: .signature, params: signature, commitment: commitment, encoding: "base64")
    }

    /// Subscribe to `logsNotification`
    /// - Parameter mentions: accounts to be subscribed
    /// - Returns: id of the request
    @discardableResult func logsSubscribe(mentions: [String], commitment: String = "confirmed") async throws -> String {
        try await subscribe(type: .logs, params: ["mentions": mentions], commitment: commitment, encoding: "base64")
    }

    /// Subscribe to all events
    /// - Returns: id of the request
    @discardableResult func logsSubscribeAll(commitment: String = "confirmed") async throws -> String {
        try await subscribe(type: .logs, params: "all", commitment: commitment, encoding: "base64")
    }

    /// Subscribe to `programNotification`
    /// - Parameter publickey: program to be subscribed
    /// - Returns: id of the request
    @discardableResult func programSubscribe(publickey: String,
                                             commitment: String = "confirmed") async throws -> String
    {
        try await subscribe(type: .program, params: publickey, commitment: commitment, encoding: "base64")
    }
}

public class Socket: NSObject, SolanaSocket {
    // MARK: - Properties

    /// Connection status of the socket
    public var isConnected: Bool = false

    /// Socket task to handle socket event
    private var task: WebSocketTask!

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
        socketTaskProviderType _: T.Type
    ) {
        super.init()
        let urlSession = T(configuration: .default, delegate: self, delegateQueue: .current!)
        task = urlSession.createWebSocketTask(with: url)
    }

    /// Convenience initializer for socket using `URLSession` as `WebSocketTaskProvider`
    /// - Parameters:
    ///   - url: url of the socket
    ///   - enableDebugLogs: enable/disable logging
    public convenience init(
        url: URL
    ) {
        self.init(url: url, socketTaskProviderType: URLSession.self)
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

    /// Subscribe to an entity ('account', 'program', 'signature', for example)
    /// - Parameters:
    ///   - type: type of entity, '.account', '.program',...
    ///   - params: params to be sent
    /// - Returns: id of the request
    @discardableResult public func subscribe<T: Encodable>(
        type entity: SocketEntity, params: T,
        commitment: String,
        encoding: String
    ) async throws -> String {
        let method: SocketMethod = .init(entity, .subscribe)
        let params: [Encodable] = [params, ["commitment": commitment, "encoding": encoding]]
        let request = RequestAPI(method: method.rawValue, params: params)
        return try await writeToSocket(request: request)
    }

    /// Unsubscribe to an entity ('account', 'program', 'signature', for example)
    /// - Parameters:
    ///   - type: type of entity, '.account', '.program',...
    ///   - socketId: id of the subscription
    /// - Returns: id of the request
    @discardableResult public func unsubscribe(type entity: SocketEntity, socketId: UInt64) async throws -> String {
        let method: SocketMethod = .init(entity, .unsubscribe)
        let params: [Encodable] = [socketId]
        let request = RequestAPI(method: method.rawValue, params: params)
        return try await writeToSocket(request: request)
    }

    /// Emit message to socket
    /// - Parameter request: request to be sent
    /// - Returns: request id
    @discardableResult private func writeToSocket(request: RequestAPI) async throws -> String {
        let jsonData = try JSONEncoder().encode(request)
        Logger.log(event: "request", message: "\(String(data: jsonData, encoding: .utf8) ?? "")", logLevel: .info)
        try await task.send(.data(jsonData))
        return request.id
    }

    /// Read message from socket one at a time
    private func readMessage() async throws {
        try Task.checkCancellation()
        let message = try await task.receive()
        switch message {
        case let .string(text):
            Logger.log(event: "event", message: "Receive string from socket: \(text)", logLevel: .debug)
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
                        if let notification = try? JSONDecoder()
                            .decode(SocketNativeAccountNotification.self, from: data)
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
                       let id = subscription.id
                    {
                        delegate?.subscribed(socketId: socketId, id: id)
                    }

                    if let subscription = try? JSONDecoder().decode(SocketUnsubscriptionResponse.self, from: data),
                       subscription.result == true,
                       let id = subscription.id
                    {
                        delegate?.unsubscribed(id: id)
                    }
                }
            } catch {
                delegate?.error(error: error)
            }
        case let .data(data):
            print("Received binary message: \(data)")
        @unknown default:
            fatalError()
        }
    }

    private func ping() {
        Logger.log(event: "request", message: "Ping socket", logLevel: .debug)
        task.sendPing { error in
            if let error = error {
                print("Ping failed: \(error)")
            }
        }
    }
}

extension Socket: URLSessionWebSocketDelegate {
    public func urlSession(_: URLSession, webSocketTask _: URLSessionWebSocketTask, didOpenWithProtocol _: String?) {
        isConnected = true
        wsHeartBeat?.invalidate()
        wsHeartBeat = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            // Ping server every 5s to prevent idle timeouts
            self?.ping()
        }
        delegate?.connected()

        Logger.log(event: "urlSession", message: "Socket disconnected", logLevel: .debug)

        asyncTask = Task.detached { [weak self] in
            while true {
                guard let self = self else { break }
                try await self.readMessage()
            }
        }
    }

    public func urlSession(
        _: URLSession,
        webSocketTask _: URLSessionWebSocketTask,
        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
        reason: Data?
    ) {
        isConnected = false
        wsHeartBeat?.invalidate()
        task.resume()
        delegate?.disconnected(reason: reason?.jsonString ?? "", code: closeCode.rawValue)

        Logger.log(event: "urlSession", message: "Socket disconnected", logLevel: .debug)

        asyncTask?.cancel()
    }
}
