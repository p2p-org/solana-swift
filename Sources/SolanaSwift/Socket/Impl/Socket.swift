import Foundation
import LoggerSwift

public class Socket: NSObject, SolanaSocket {
    // MARK: - Properties
    var isConnected: Bool = false
    private var urlSession: URLSession!
    private(set) var task: URLSessionWebSocketTask!
    var wsHeartBeat: Timer!
    
    let subscribingResultsStream = SocketResponseStream<Result<SubscribingResultResponse, Error>>()
    let subscriptionsStorages = SubscriptionsStorages()
    
    // MARK: - Initializers
    init(endpoint: String) {
        super.init()
        self.urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        self.task = urlSession.webSocketTask(with: .init(string: endpoint)!)
        
        defer { connect() }
    }
    
    deinit {
        task.cancel(with: .goingAway, reason: nil)
        clean()
        subscribingResultsStream.onFinish?()
        subscriptionsStorages.onFinish()
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
        guard await !subscriptionsStorages.isSubscriptionExists(item: account)
        else { return /* already subscribed */ }
        
        // add account to observing list
        await subscriptionsStorages.insertObservableItem(account)
        
        // subscribe
        Task.detached { [weak self] in
            try await self?.subscribe(item: account)
        }
    }
    
    func removeFromObserving(account: String) async throws {
        // check if any subscription of account exists
        guard let subscription = await subscriptionsStorages.findSubscription(
            account: account,
            type: SocketObservableAccount.self
        ) else { return /* not yet subscribed */ }
        
        // remove from observing list
        await subscriptionsStorages.removeObservingItem(subscription.item)
        
        // write
        Task.detached { [weak self] in
            try await self?.cancelSubscription(subscription)
        }
        
    }
    
    func observeAllAccounts() -> SocketResponseStream<Result<SocketObservableAccount, Error>> {
        subscriptionsStorages.accountInfoStream
    }
    
    func observe(account: String) async throws -> AsyncFilterSequence<SocketResponseStream<Result<SocketObservableAccount, Error>>> {
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
            entity: .signature,
            entityValue: signature
        )
        
        guard let subscription = await subscriptionsStorage.activeSignatureSubscriptions.first(where: {$0.account == signature})
        else {
            throw SolanaError.other("Subscription not found")
        }
        return signatureInfoStream.filter {$0.subscription == subscription.id}
    }
}
