import Foundation

/// BlockchainClient that prepares and serialises transaction to send to blockchain
public protocol SolanaBlockchainClient: AnyObject {
    associatedtype APIClient: SolanaAPIClient
    
    /// APIClient for handling network requests
    var apiClient: APIClient { get set }
    
    /// Prepare a transaction base on its instructions
    /// - Parameters:
    ///   - instructions: instructions of the transaction
    ///   - signers: the signers
    ///   - feePayer: the feePayer, usually is the first signer
    ///   - recentBlockhash: recentBlockhash, can be fetched lately when the value is nil
    ///   - feeCalculator: the fee calculator, leave it nil to use DefaultFeeCalculator
    /// - Returns: information of a prepared transaction
    func prepareTransaction(
        instructions: [TransactionInstruction],
        signers: [Account],
        feePayer: PublicKey,
        recentBlockhash: String?,
        feeCalculator: FeeCalculator?
    ) async throws -> PreparedTransaction
    
    /// Sign and Serialize PreparedTransaction for sending
    /// - Parameter preparedTransaction: a prepared transaction
    /// - Returns: Serialized transaction which is ready to be sent
    func signAndSerialize(
        preparedTransaction: PreparedTransaction
    ) throws -> String
    
    /// Send transaction
    /// - Parameter preparedTransaction: a prepared transaction
    /// - Returns: Transaction id
    func sendTransaction(
        preparedTransaction: PreparedTransaction
    ) async throws -> String
    
    /// Simulate transaction
    /// - Parameter preparedTransaction: a prepared transaction
    func simulateTransaction(
        preparedTransaction: PreparedTransaction
    ) async throws -> TransactionStatus
}

extension SolanaBlockchainClient {
    public func signAndSerialize(
        preparedTransaction: PreparedTransaction
    ) throws -> String {
        var preparedTransaction = preparedTransaction
        try preparedTransaction.sign()
        return try preparedTransaction.serialize()
    }
    
    public func sendTransaction(
        preparedTransaction: PreparedTransaction
    ) async throws -> String {
        let serializedTransaction = try signAndSerialize(preparedTransaction: preparedTransaction)
        return try await apiClient.sendTransaction(transaction: serializedTransaction)
    }
    
    public func simulateTransaction(
        preparedTransaction: PreparedTransaction
    ) async throws -> TransactionStatus {
        let serializedTransaction = try signAndSerialize(preparedTransaction: preparedTransaction)
        return try await apiClient.simulateTransaction(transaction: serializedTransaction)
    }
}
