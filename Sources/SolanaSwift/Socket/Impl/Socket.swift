import Foundation
import LoggerSwift

public class Socket: NSObject, SolanaSocket {
    // MARK: - Properties
    var isConnected: Bool = false
    private var urlSession: URLSession!
    private(set) var task: URLSessionWebSocketTask!
    private var wsHeartBeat: Timer!
    
    // MARK: - Streams
    let subscribingResultsStream = SocketResponseStream<SubscribingResultResponse>()
    private let accountInfoStream = SocketResponseStream<SocketAccountResponse>()
    private let signatureInfoStream = SocketResponseStream<SocketSignatureResponse>()
    
    // MARK: - Subscriptions
    let subscriptionsStorage = SubscriptionsStorage()
    
    // MARK: - Initializers
    init(endpoint: String) {
        
        self.urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        self.task = urlSession.webSocketTask(with: .init(string: endpoint)!)
        
        defer { connect() }
    }
    
    deinit {
        task.cancel(with: .goingAway, reason: nil)
        clean()
        accountInfoStream.onFinish?()
        signatureInfoStream.onFinish?()
        subscribingResultsStream.onFinish?()
    }
    
    // MARK: - Methods
    func connect() {
        clean()
        task.resume()
    }
    
    func disconnect() {
        clean()
        isConnected = false
        task.cancel(with: .goingAway, reason: nil)
    }
    
    func addToObserving(account: SocketObservableAccount) async throws {
        // check if any subscription of account exists
        guard await !subscriptionsStorage.subscriptionExists(account: account.pubkey)
        else { return /* already subscribed */ }
        
        // add account to observing list
        await subscriptionsStorage.insertObservableAccount(account)
        
        // subscribe
        Task.detached { [weak self] in
            try await self?.subscribe(
                method: .init(.account, .subscribe),
                params: [
                    account.pubkey,
                    ["encoding":"base64", "commitment": "recent"]
                ],
                account: account.pubkey
            )
        }
    }
    
    func removeFromObserving(account: String) async throws {
        // check if any subscription of account exists
        guard let subscription = await subscriptionsStorage.activeAccountSubscriptions.first(where: {$0.account == account})
        else { return /* not yet subscribed */ }
        
        // remove from observing list
        await subscriptionsStorage.removeObservingAccount(account)
        
        // write
        Task.detached { [weak self] in
            try await self?.cancelSubscription(subscription)
        }
        
    }
    
    func observeAllAccounts() -> SocketResponseStream<SocketAccountResponse> {
        accountInfoStream
    }
    
    func observe(account: String) async throws -> AsyncFilterSequence<SocketResponseStream<SocketAccountResponse>> {
        guard let subscription = await subscriptionsStorage.activeAccountSubscriptions.first(where: {$0.account == account})
        else {
            throw SolanaError.other("Subscription not found")
        }
        return accountInfoStream.filter {$0.subscription == subscription.id}
    }
    
    func observe(signature: String) async throws -> AsyncFilterSequence<SocketResponseStream<SocketSignatureResponse>> {
        // subscribe first
        try await subscribe(
            method: .init(.signature, .subscribe),
            params: [signature, ["commitment": "confirmed"]],
            account: signature
        )
        
        guard let subscription = await subscriptionsStorage.activeAccountSubscriptions.first(where: {$0.account == signature})
        else {
            throw SolanaError.other("Subscription not found")
        }
        return signatureInfoStream.filter {$0.subscription == subscription.id}
    }
    
    // MARK: - Helpers
    /// Clean the environment
    private func clean() {
        Task {
            try await unsubscribeAllObservingAccounts()
        }
        wsHeartBeat?.invalidate()
        wsHeartBeat = nil
    }
    
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
            try await reconnect()
        }
    }
    
    /// Subscribe to accountNotification from all accounts in the queue
    private func subscribeToAllAccounts() async {
        let observingAccounts = await subscriptionsStorage.observingAccounts
        for account in observingAccounts {
            Task {
                try await addToObserving(account: account)
            }
        }
    }
    
    /// Remove all current subscriptions
    private func unsubscribeAllObservingAccounts() async throws {
        for subscription in await subscriptionsStorage.activeAccountSubscriptions {
            Task.detached { [weak self] in
                try await self?.cancelSubscription(subscription)
            }
        }
    }
    
    /// Cancel a subscription
    /// - Parameter subscription: subscription to cancel
    private func cancelSubscription(_ subscription: SocketSubscription) async throws {
        try await write(method: .init(subscription.entity, .unsubscribe), params: [subscription.id])
        await subscriptionsStorage.cancelSubscription(subscription)
    }
    
    /// Reconnect when error
    fileprivate func reconnect(delayInSeconds: UInt64 = 3) async throws {
        // TODO: - Handle error
        try await Task.sleep(nanoseconds: 1_000_000 * delayInSeconds)
        task.resume()
    }
}

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
