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
        let message = try await task.receive()
        switch message {
        case .string(let string):
            guard let data = string.data(using: .utf8) else { return }
            // TODO: - Parse object
            // Parse subscription
            if let subscriptionResult = try? JSONDecoder().decode(Response<UInt64>.self, from: data) {
                subscribingResultsStream.onReceiving?(.init(requestId: subscriptionResult.id, subscriptionId: subscriptionResult.result))
            } else if let
        case .data(_):
            break
        @unknown default:
            break
        }
        try await receiveNewMessage()
    }
    
    /// Subscribe to accountNotification from all accounts in the queue
    func subscribeToAllAccounts() async {
        let observingAccounts = await subscriptionsStorages.accountSubscriptionsStorage.observingItems
        for account in observingAccounts {
            Task {
                try await addToObserving(account: account)
            }
        }
    }
    
    /// Remove all current subscriptions
    func unsubscribeAllObservingAccounts() async throws {
        for subscription in await subscriptionsStorages.accountSubscriptionsStorage.activeSubscriptions {
            Task.detached { [weak self] in
                try await self?.cancelSubscription(subscription)
            }
        }
    }
    
    /// Cancel a subscription
    /// - Parameter subscription: subscription to cancel
    func cancelSubscription<T: SocketObservableItem>(_ subscription: SocketSubscription<T>) async throws {
        try await write(method: .init(subscription.item.entity, .unsubscribe), params: [subscription.id])
        await subscriptionsStorages.clearSubscription(subscription)
    }
    
    /// Reconnect when error
    func reconnect(delayInSeconds: UInt64 = 3) async throws {
        // TODO: - Handle error
        try await Task.sleep(nanoseconds: 1_000_000 * delayInSeconds)
        task.resume()
    }
}
