import Foundation

public protocol SolanaSocketEventsDelegate: AnyObject {
    func connected()
    func nativeAccountNotification(notification: Response<BufferInfo<AccountInfo>>)
    func tokenAccountNotification(notification: Response<BufferInfoParsed<SocketTokenAccountNotificationData>>)
    func programNotification(notification: Response<ProgramAccount<AccountInfo>>)
    func signatureNotification(notification: Response<SocketSignatureNotification>)
    func logsNotification(notification: Response<SocketLogsNotification>)
    func unsubscribed(id: String)
    func subscribed(socketId: UInt64, id: String)
    func disconnected(reason: String, code: UInt16)
    func error(error: Error?)
}

public class SolanaSocket: NSObject {
    // MARK: - Properties
    var isConnected: Bool = false
    
    private var task: URLSessionWebSocketTask!
    private let enableDebugLogs: Bool
    private var wsHeartBeat: Timer!
    
    // MARK: - Delegation
    public weak var delegate: SolanaSocketEventsDelegate?
    
    // MARK: - Initializers
    init<T: WebSocketTaskProvider>(
        url: URL,
        enableDebugLogs: Bool,
        socketTaskProviderType: T.Type = URLSession.self as! T.Type
    ) {
        self.enableDebugLogs = enableDebugLogs
        super.init()
        let urlSession = T(configuration: .default, delegate: self, delegateQueue: .current!)
        self.task = urlSession.createWebSocketTask(with: url)
    }
    
    deinit {
        disconnect()
    }
    
    // MARK: - Methods
    public func connect() {
        task.resume()
    }
    
    public func disconnect() {
        task.cancel()
        delegate = nil
        wsHeartBeat?.invalidate()
        wsHeartBeat = nil
    }
    
    public func accountSubscribe(publickey: String) async throws -> String {
        let method: SocketMethod = .accountSubscribe
        let params: [Encodable] = [ publickey, ["commitment": "recent", "encoding": "base64"] ]
        let request = RequestAPI(method: method.rawValue, params: params)
        return try await writeToSocket(request: request)
    }
    
    func accountUnsubscribe(socketId: UInt64) async throws -> String {
        let method: SocketMethod = .accountUnsubscribe
        let params: [Encodable] = [socketId]
        let request = RequestAPI(method: method.rawValue, params: params)
        return try await writeToSocket(request: request)
    }
    
    public func signatureSubscribe(signature: String) async throws -> String {
        let method: SocketMethod = .signatureSubscribe
        let params: [Encodable] = [signature, ["commitment": "confirmed", "encoding": "base64"]]
        let request = RequestAPI(method: method.rawValue, params: params)
        return try await writeToSocket(request: request)
    }
    
    func signatureUnsubscribe(socketId: UInt64) async throws -> String {
        let method: SocketMethod = .signatureUnsubscribe
        let params: [Encodable] = [socketId]
        let request = RequestAPI(method: method.rawValue, params: params)
        return try await writeToSocket(request: request)
    }
    
    public func logsSubscribe(mentions: [String]) async throws -> String {
        let method: SocketMethod = .logsSubscribe
        let params: [Encodable] = [["mentions": mentions], ["commitment": "confirmed", "encoding": "base64"]]
        let request = RequestAPI(method: method.rawValue, params: params)
        return try await writeToSocket(request: request)
    }
    
    public func logsSubscribeAll() async throws -> String {
        let method: SocketMethod = .logsSubscribe
        let params: [Encodable] = ["all", ["commitment": "confirmed", "encoding": "base64"]]
        let request = RequestAPI(method: method.rawValue, params: params)
        return try await writeToSocket(request: request)
    }
    
    func logsUnsubscribe(socketId: UInt64) async throws -> String {
        let method: SocketMethod = .logsUnsubscribe
        let params: [Encodable] = [socketId]
        let request = RequestAPI(method: method.rawValue, params: params)
        return try await writeToSocket(request: request)
    }
    
    public func programSubscribe(publickey: String) async throws -> String {
        let method: SocketMethod = .programSubscribe
        let params: [Encodable] = [publickey, ["commitment": "confirmed", "encoding": "base64"]]
        let request = RequestAPI(method: method.rawValue, params: params)
        return try await writeToSocket(request: request)
    }
    
    func programUnsubscribe(socketId: UInt64) async throws -> String {
        let method: SocketMethod = .programUnsubscribe
        let params: [Encodable] = [socketId]
        let request = RequestAPI(method: method.rawValue, params: params)
        return try await writeToSocket(request: request)
    }
    
    private func writeToSocket(request: RequestAPI) async throws -> String {
        guard let jsonData = try? JSONEncoder().encode(request) else {
            throw SocketError.couldNotSerialize
        }
        try await task.send(.data(jsonData))
        return request.id
    }
    
    private func readMessage() async throws {
        let message = try await task.receive()
        switch message {
        case .string(let text):
            guard let data = text.data(using: .utf8) else { return }
            do {
                // TODO: Fix this mess code
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                if let jsonType = jsonResponse["method"] as? String,
                   let type = SocketMethod(rawValue: jsonType) {
                    
                    switch type {
                    case .accountNotification:
                        if let notification = try? JSONDecoder().decode(Response<BufferInfo<AccountInfo>>.self, from: data)
                        {
                            delegate?.nativeAccountNotification(notification: notification)
                        } else {
                            let notification = try JSONDecoder().decode(Response<BufferInfoParsed<SocketTokenAccountNotificationData>>.self, from: data)
                            delegate?.tokenAccountNotification(notification: notification)
                        }
                        
                    case .signatureNotification:
                        let notification = try JSONDecoder().decode(Response<SocketSignatureNotification>.self, from: data)
                        delegate?.signatureNotification(notification: notification)
                    case .logsNotification:
                        let notification = try JSONDecoder().decode(Response<SocketLogsNotification>.self, from: data)
                        delegate?.logsNotification(notification: notification)
                    case .programNotification:
                        let notification = try JSONDecoder().decode(Response<ProgramAccount<AccountInfo>>.self, from: data)
                        delegate?.programNotification(notification: notification)
                    default: break
                    }
                    
                } else {
                    if let subscription = try? JSONDecoder().decode(Response<UInt64>.self, from: data),
                       let socketId = subscription.result,
                       let id = subscription.id {
                        delegate?.subscribed(socketId: socketId, id: id)
                    }
                    
                    if let subscription = try? JSONDecoder().decode(Response<Bool>.self, from: data),
                       subscription.result == true,
                       let id = subscription.id {
                        delegate?.unsubscribed(id: id)
                    }
                }
            } catch let error {
                delegate?.error(error: error)
            }
        case .data(let data):
            print("Received binary message: \(data)")
        @unknown default:
            fatalError()
        }
        
        try await self.readMessage()
    }
    
    private func ping() {
        task.sendPing { (error) in
            if let error = error {
                print("Ping failed: \(error)")
            }
        }
    }
}

extension SolanaSocket: URLSessionWebSocketDelegate {
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        isConnected = true
        wsHeartBeat?.invalidate()
        wsHeartBeat = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] (_) in
            // Ping server every 5s to prevent idle timeouts
            self?.ping()
        }
    }
    
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        isConnected = false
        wsHeartBeat?.invalidate()
        task.resume()
    }
}
