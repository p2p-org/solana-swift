import Foundation

class Socket: NSObject {
    // MARK: - Properties
    var urlSession: URLSession!
    var task: URLSessionWebSocketTask!
    let accountInfoStream = SocketResponseStream<SocketAccountResponse>()
    let signatureInfoStream = SocketResponseStream<SocketSignatureResponse>()
    
    // MARK: - Initializers
    init(endpoint: String) {
        
        self.urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        self.task = urlSession.webSocketTask(with: .init(string: endpoint)!)
        
        defer { task.resume() }
    }
    
    // MARK: - Methods
    func disconnect() {
        task.cancel(with: .goingAway, reason: nil)
    }
    
    // MARK: - Helpers
    /// Request to get new message
    private func receiveNewMessage() async throws {
        do {
            let message = try await task.receive()
            switch message {
            case .string(_):
                // TODO: - Parse object
            case .data(_):
                break
            @unknown default:
                break
            }
            try await receiveNewMessage()
        } catch {
            accountInfoStream.onFailure?(error)
            signatureInfoStream.onFailure?(error)
            // TODO: - Handle error
        }
    }
    
    /// If your app is not sending messages over WebSocket with "acceptable" frequency, the server may drop your connection due to inactivity.
    /// Special ping-pong messages are used to solve this problem.
    private func ping() {
        task.sendPing { [weak self] error in
            if let error = error {
                print("Ping failed: \(error)")
            }
            self?.scheduleNextPing()
        }
    }
}

extension Socket: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        <#code#>
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        <#code#>
    }
}
