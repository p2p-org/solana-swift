import Foundation

public protocol SolanaSocketEventsDelegate: AnyObject {
    func connected()
    func accountNotification(notification: Response<BufferInfo<AccountInfo>>)
    func programNotification(notification: Response<ProgramAccount<AccountInfo>>)
    func signatureNotification(notification: Response<SocketSignatureNotification>)
    func logsNotification(notification: Response<SocketLogsNotification>)
    func unsubscribed(id: String)
    func subscribed(socketId: UInt64, id: String)
    func disconnected(reason: String, code: UInt16)
    func error(error: Error?)
}

protocol WebSocketTaskProvider {
    func createWebSocketTask<T: WebSocketTask>(with url: URL) -> T
}

extension URLSession: WebSocketTaskProvider {
    func createWebSocketTask<T: WebSocketTask>(with url: URL) -> T {
        webSocketTask(with: url) as! T
    }
}

protocol WebSocketTask {
    func resume()
    func cancel()
    func receive() async throws -> URLSessionWebSocketTask.Message
}

extension URLSessionWebSocketTask: WebSocketTask {
    
}

public class SolanaSocket {
    private let task: URLSessionWebSocketTask
    private var enableDebugLogs: Bool
    
    public weak var delegate: SolanaSocketEventsDelegate?
    
    init(url: URL, enableDebugLogs: Bool = false, socketTaskProvider: URLSession = URLSession.shared) {
        self.task = socketTaskProvider.webSocketTask(with: url)
        self.enableDebugLogs = enableDebugLogs
    }
    
    public func start() {
        task.resume()
    }
    
    public func stop() {
        task.cancel()
        delegate = nil
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
            print("Received text message: \(text)")
        case .data(let data):
            print("Received binary message: \(data)")
        @unknown default:
            fatalError()
        }
        
        try await self.readMessage()
    }
}

extension SolanaSocket: WebSocketDelegate {
    
    public func didReceive(event: WebSocketEvent, client: WebSocket) {
        log(event: event)
        switch event {
        case .connected:
            delegate?.connected()
        case .disconnected(let reason, let code):
            delegate?.disconnected(reason: reason, code: code)
        case .text(let string):
            onText(string: string)
        case .binary: break
        case .ping: break
        case .pong: break
        case .viabilityChanged: break
        case .reconnectSuggested: break
        case .cancelled: break
        case .error(let error): break
            self.delegate?.error(error: error)
        }
    }
    
    private func log(event: WebSocketEvent) {
        guard enableDebugLogs else {return}
        switch event {
        case .connected(let headers):
            debugPrint("conected with headers \(headers)")
        case .disconnected(let reason, let code):
            debugPrint("disconnected with reason \(reason) \(code)")
        case .text(let string):
            debugPrint("text \(string)")
        case .binary:
            debugPrint("binary")
        case .ping:
            debugPrint("ping")
        case .pong:
            debugPrint("pong")
        case .viabilityChanged(let visible):
            debugPrint("viabilityChanged \(visible)")
        case .reconnectSuggested(let reconnect):
            debugPrint("reconnectSuggested \(reconnect)")
        case .cancelled:
            debugPrint("cancelled")
        case .error(let error):
            debugPrint("error \(error?.localizedDescription ?? "")")
        }
    }
    
    private func onText(string: String) {
        guard let data = string.data(using: .utf8) else { return }
        do {
            // TODO: Fix this mess code
            let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            if let jsonType = jsonResponse["method"] as? String,
               let type = SocketMethod(rawValue: jsonType) {
                
                switch type {
                case .accountNotification:
                    let notification = try JSONDecoder().decode(Response<BufferInfo<AccountInfo>>.self, from: data)
                    delegate?.accountNotification(notification: notification)
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
    }
    
}
