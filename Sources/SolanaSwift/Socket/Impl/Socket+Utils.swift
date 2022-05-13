import Foundation

extension Socket {
    /// Clean the environment
    func clean() {
        Task {
            try await unsubscribeAllObservingAccounts()
        }
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
            try await reconnect()
        }
    }
    
    /// Subscribe to accountNotification from all accounts in the queue
    func subscribeToAllAccounts() async {
        let observingAccounts = await subscriptionsStorage.observingAccounts
        for account in observingAccounts {
            Task {
                try await addToObserving(account: account)
            }
        }
    }
    
    /// Remove all current subscriptions
    func unsubscribeAllObservingAccounts() async throws {
        for subscription in await subscriptionsStorage.activeAccountSubscriptions {
            Task.detached { [weak self] in
                try await self?.cancelSubscription(subscription)
            }
        }
    }
    
    /// Cancel a subscription
    /// - Parameter subscription: subscription to cancel
    func cancelSubscription(_ subscription: SocketSubscription) async throws {
        try await write(method: .init(subscription.entity, .unsubscribe), params: [subscription.id])
        await subscriptionsStorage.cancelSubscription(subscription)
    }
    
    /// Reconnect when error
    func reconnect(delayInSeconds: UInt64 = 3) async throws {
        // TODO: - Handle error
        try await Task.sleep(nanoseconds: 1_000_000 * delayInSeconds)
        task.resume()
    }
}
