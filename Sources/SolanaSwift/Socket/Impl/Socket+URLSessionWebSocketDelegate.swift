import Foundation
import LoggerSwift

extension Socket: URLSessionWebSocketDelegate {
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        Task {
            try await onOpen()
        }
    }
    
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        Task {
            try await onClosed()
        }
    }
    
    private func onOpen() async throws {
        // wipe old subscriptions
        try await unsubscribeAllObservingAccounts()
        
        // set heart beat
        wsHeartBeat?.invalidate()
        wsHeartBeat = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] (_) in
            // Ping server every 5s to prevent idle timeouts
            self?.ping()
        }
        
        // resubscribe
        await subscribeToAllAccounts()
        
        // mark as connected
        isConnected = true
        
        // get new message
        try await receiveNewMessage()
    }
    
    private func onClosed() async throws {
        clean()
        
        // mark as not connected
        isConnected = false
        
        try await reconnect()
    }
    
    /// If your app is not sending messages over WebSocket with "acceptable" frequency, the server may drop your connection due to inactivity.
    /// Special ping-pong messages are used to solve this problem.
    private func ping() {
        task.sendPing { error in
            if let error = error {
                Logger.log(event: .error, message: "Ping failed: \(error)")
            }
        }
    }
}
