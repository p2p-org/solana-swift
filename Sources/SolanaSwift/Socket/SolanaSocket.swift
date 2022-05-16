import Starscream
import Foundation

enum SocketError: Error {
    case disconnected
    case couldNotSerialize
}
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

public class SolanaSocket {
    private var socket: WebSocket?
    private var enableDebugLogs: Bool
    private var request: URLRequest
    private weak var delegate: SolanaSocketEventsDelegate?

    init(url: URL, enableDebugLogs: Bool = false) {
        self.request = URLRequest(url: url)
        self.request.timeoutInterval = 5
        self.enableDebugLogs = enableDebugLogs
    }

    public func start(delegate: SolanaSocketEventsDelegate) {
        self.delegate = delegate
        self.socket = WebSocket(request: request)
        socket?.delegate = self
        socket?.connect()
    }

    public func stop() {
        self.socket?.disconnect()
        self.delegate = nil
    }

    public func accountSubscribe(publickey: String) -> Result<String, Error> {
        let method: SocketMethod = .accountSubscribe
        let params: [Encodable] = [ publickey, ["commitment": "recent", "encoding": "base64"] ]
        let request = RequestAPI(method: method.rawValue, params: params)
        return writeToSocket(request: request)
    }

    func accountUnsubscribe(socketId: UInt64) -> Result<String, Error> {
        let method: SocketMethod = .accountUnsubscribe
        let params: [Encodable] = [socketId]
        let request = RequestAPI(method: method.rawValue, params: params)
        return writeToSocket(request: request)
    }

    public func signatureSubscribe(signature: String) -> Result<String, Error> {
        let method: SocketMethod = .signatureSubscribe
        let params: [Encodable] = [signature, ["commitment": "confirmed", "encoding": "base64"]]
        let request = RequestAPI(method: method.rawValue, params: params)
        return writeToSocket(request: request)
    }

    func signatureUnsubscribe(socketId: UInt64) -> Result<String, Error> {
        let method: SocketMethod = .signatureUnsubscribe
        let params: [Encodable] = [socketId]
        let request = RequestAPI(method: method.rawValue, params: params)
        return writeToSocket(request: request)
    }

    public func logsSubscribe(mentions: [String]) -> Result<String, Error> {
        let method: SocketMethod = .logsSubscribe
        let params: [Encodable] = [["mentions": mentions], ["commitment": "confirmed", "encoding": "base64"]]
        let request = RequestAPI(method: method.rawValue, params: params)
        return writeToSocket(request: request)
    }

    public func logsSubscribeAll() -> Result<String, Error> {
        let method: SocketMethod = .logsSubscribe
        let params: [Encodable] = ["all", ["commitment": "confirmed", "encoding": "base64"]]
        let request = RequestAPI(method: method.rawValue, params: params)
        return writeToSocket(request: request)
    }

    func logsUnsubscribe(socketId: UInt64) -> Result<String, Error> {
        let method: SocketMethod = .logsUnsubscribe
        let params: [Encodable] = [socketId]
        let request = RequestAPI(method: method.rawValue, params: params)
        return writeToSocket(request: request)
    }

    public func programSubscribe(publickey: String) -> Result<String, Error> {
        let method: SocketMethod = .programSubscribe
        let params: [Encodable] = [publickey, ["commitment": "confirmed", "encoding": "base64"]]
        let request = RequestAPI(method: method.rawValue, params: params)
        return writeToSocket(request: request)
    }

    func programUnsubscribe(socketId: UInt64) -> Result<String, Error> {
        let method: SocketMethod = .programUnsubscribe
        let params: [Encodable] = [socketId]
        let request = RequestAPI(method: method.rawValue, params: params)
        return writeToSocket(request: request)
    }

    private func writeToSocket(request: RequestAPI) -> Result<String, Error> {
        guard let jsonData = try? JSONEncoder().encode(request) else { return Result.failure(SocketError.couldNotSerialize) }
        guard let socket = socket else { return Result.failure(SocketError.disconnected) }
        socket.write(data: jsonData)
        return Result.success(request.id)
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
