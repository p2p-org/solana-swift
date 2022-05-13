import Foundation

protocol SolanaSocket {
    /// Connection status of the socket
    var isConnected: Bool {get}
    
    /// Connect to socket
    func connect()
    
    /// Disconnect from socket
    func disconnect()
    
    /// Add account to observing list, can be native account or spl token account
    /// - Parameters:
    ///   - object: Object that needs to be observed
    func addToObserving(account: SocketObservableAccount) async throws
    
    /// Remove account from observing list
    /// - Parameter account: account to be removed from observing list
    func removeFromObserving(account: String)
    
    /// Observe notifications of all accounts in observing list
    /// - Returns: Stream of SocketAccountResponse
    func observeAllAccounts() -> SocketResponseStream<SocketAccountResponse>
    
    /// Observe notifications of an account
    /// - Parameter account: account to be observed
    /// - Returns: Stream of SocketAccountResponse
    func observe(account: String) -> SocketResponseStream<SocketAccountResponse>
    
    /// Observe status of a signature
    /// - Parameter signature: signature to observe
    /// - Returns: Sequence of statuses of the signature
    func observe(signature: String) -> SocketResponseStream<SocketSignatureResponse>
}