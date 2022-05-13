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
    
    func observeAllAccounts() -> SocketResponseStream<Result<SocketAccountResponse, Error>> {
        subscriptionsStorages.accountInfoStream
    }
    
    func observe(account: String) async throws -> AsyncFilterSequence<SocketResponseStream<Result<SocketAccountResponse, Error>>> {
        guard let subscription = await subscriptionsStorages.findSubscription(
            account: account,
            type: SocketObservableAccount.self
        ) else { throw SocketError.subscriptionIdNotFound }
        
        return subscriptionsStorages.accountInfoStream.filter { result in
            switch result {
            case .success(let account):
                return subscription.id == account.subscription
            case .failure:
                return false
            }
        }
    }
    
    func observe(signature: String) async throws -> AsyncFilterSequence<SocketResponseStream<Result<SocketSignatureResponse, Error>>> {
        // subscribe first
        try await subscribe(item: signature as SocketObservableSignature)
        
        guard let subscription = await subscriptionsStorages.findSubscription(
            account: signature,
            type: SocketObservableSignature.self
        ) else { throw SocketError.subscriptionIdNotFound }
        
        return subscriptionsStorages.signatureInfoStream.filter { result in
            switch result {
            case .success(let signature):
                return subscription.id == signature.subscription
            case .failure:
                return false
            }
        }
    }
}
