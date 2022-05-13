import Foundation
import LoggerSwift

public class Socket: NSObject, SolanaSocket {
    // MARK: - Properties
    /// Connection status of the socket
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
    /// Connect to socket
    func connect() {
        clean()
        task.resume()
    }
    
    /// Disconnect from socket
    func disconnect() {
        clean()
        isConnected = false
        task.cancel(with: .goingAway, reason: nil)
    }
    
    /// Add account to observing list, can be native account or spl token account
    /// - Parameters:
    ///   - object: Object that needs to be observed
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
    
    /// Remove account from observing list
    /// - Parameter account: account to be removed from observing list
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
    
    /// Observe notifications of all accounts in observing list
    /// - Returns: Stream of SocketAccountResponse
    func observeAllAccounts() -> SocketResponseStream<Result<SocketAccountResponse, Error>> {
        subscriptionsStorages.accountInfoStream
    }
    
    /// Observe notifications of an account
    /// - Parameter account: account to be observed
    /// - Returns: Stream of SocketAccountResponse
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
    
    /// Observe status of a signature
    /// - Parameter signature: signature to observe
    /// - Returns: Sequence of statuses of the signature
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
