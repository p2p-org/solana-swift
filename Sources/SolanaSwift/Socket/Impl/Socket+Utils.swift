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
            // Get needed data
            guard let data = string.data(using: .utf8),
                  let json = (try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves)) as? [String: Any]
            else {
                break
            }
            
            // subscribe request
            if let id = json["id"] as? String {
                // subscribe
                guard let result = json["result"] as? UInt64 else {
                    subscribingResultsStream.onReceiving?(.failure(SocketError.subscriptionFailed(id: id)))
                    break
                }
                // successfully subscribed
                subscribingResultsStream.onReceiving?(.success(.init(requestId: id, subscriptionId: result)))
            }
            
            // notification
            else if let method = json["method"] as? String {
                if method == "accountNotification" {
                    do {
                        guard let parsedData = try JSONDecoder().decode(
                            SocketResponse<SocketResponseParams<SocketAccountResponse>>.self, from: data
                        )
                            .params?.result
                        else {
//                            subscriptionsStorages.accountInfoStream.onReceiving?)(.failure(SocketError.accountResponseError(<#T##SocketObservableAccount#>)))
                            break
                        }
                        subscriptionsStorages.accountInfoStream.onReceiving?(
                            .success(
                                parsedData.params?.result
                            )
                        )
                    } catch {
                        subscriptionsStorages.accountInfoStream.onReceiving?(
                            .failure(
                                SocketError.
                            )
                        )
                    }
                }
                
            }
            
            // another
            else {
                break
            }
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
