import Foundation

extension Socket {
    /// Clean the environment
    func clean() {
        unsubscribeAllObservingAccounts()
        wsHeartBeat?.invalidate()
        wsHeartBeat = nil
    }
    
    /// Request to get new message
    func receiveNewMessage() async throws {
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
    func ping() {
        task.sendPing { [weak self] error in
            if let error = error {
                print("Ping failed: \(error)")
            }
            self?.scheduleNextPing()
        }
    }
    
    /// Subscribe to accountNotification from all accounts in the queue
    func subscribeToAllAccounts() {
        observingAccounts.forEach {subscribeAccountNotification(account: $0.pubkey, isNative: $0.isNative)}
    }
    
    /// Remove all current subscriptions
    func unsubscribeAllObservingAccounts() {
        for subscription in activeAccountSubscriptions {
            write(method: .init(subscription.entity, .unsubscribe), params: [subscription.id])
        }
        activeAccountSubscriptions = []
    }
}
