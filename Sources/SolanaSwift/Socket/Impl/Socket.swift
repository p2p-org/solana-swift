import Foundation

class Socket: NSObject, SolanaSocket {
    // MARK: - Properties
    var isConnected: Bool = false
    var urlSession: URLSession!
    var task: URLSessionWebSocketTask!
    var wsHeartBeat: Timer!
    
    // MARK: - Streams
    let accountInfoStream = SocketResponseStream<SocketAccountResponse>()
    let signatureInfoStream = SocketResponseStream<SocketSignatureResponse>()
    
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
        guard await !subscriptionsStorage.subscriptionExists(account: account)
        else { return // already subscribed }
        
        // add account to observing list
        subscriptionsStorage.insertObservableAccount(account)
        
        // add subscriptions
        let id = write(
            method: .init(.account, .subscribe),
            params: [
                subscriber.pubkey,
                ["encoding":"jsonParsed", "commitment": "recent"]
            ]
        )
        subscribe(id: id)
            .subscribe(onSuccess: {[weak self] subscriptionId in
                guard let strongSelf = self else {return}
                if strongSelf.accountSubscriptions.contains(where: {$0.account == subscriber.pubkey})
                {
                    strongSelf.accountSubscriptions.removeAll(where: {$0.account == subscriber.pubkey})
                }
                strongSelf.accountSubscriptions.append(.init(entity: .account, id: subscriptionId, account: subscriber.pubkey))
            })
            .disposed(by: disposeBag)
    }
    
    func removeFromObserving(account: String) {
        <#code#>
    }
    
    func observeAllAccounts() -> SocketResponseStream<SocketAccountResponse> {
        <#code#>
    }
    
    func observe(account: String) -> SocketResponseStream<SocketAccountResponse> {
        <#code#>
    }
    
    func observe(signature: String) -> SocketResponseStream<SocketSignatureResponse> {
        <#code#>
    }
    
    // MARK: - Helpers
    /// Clean the environment
    private func clean() {
        unsubscribeAllObservingAccounts()
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
    
    /// Subscribe to accountNotification from all accounts in the queue
    private func subscribeToAllAccounts() {
        observingAccounts.forEach {subscribeAccountNotification(account: $0.pubkey, isNative: $0.isNative)}
    }
    
    /// Remove all current subscriptions
    private func unsubscribeAllObservingAccounts() {
        for subscription in activeAccountSubscriptions {
            write(method: .init(subscription.entity, .unsubscribe), params: [subscription.id])
        }
        activeAccountSubscriptions = []
    }
}

extension Socket: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        // wipe old subscriptions
        unsubscribeAllObservingAccounts()
        
        // set status
        status.accept(.connected)
        
        // set heart beat
        wsHeartBeat?.invalidate()
        wsHeartBeat = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] (_) in
            // Ping server every 5s to prevent idle timeouts
            self?.ping()
        }
        
        // resubscribe
        subscribeToAllAccounts()
        
        // mark as connected
        isConnected = true
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        
        clean()
        
        // mark as not connected
        isConnected = false
        
        // TODO: - Reopen?
    }
}
