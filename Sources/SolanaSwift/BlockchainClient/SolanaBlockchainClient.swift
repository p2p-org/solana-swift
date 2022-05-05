import Foundation

/// BlockchainClient that prepares and serialises transaction to send to blockchain
public protocol SolanaBlockchainClient: AnyObject {
    /// Load all requirements before any operations from cache or network
    func load() async throws
    
    /// Update all requirements
    func update() async throws
    
    /// Prepare a transaction base on its instructions
    /// - Parameters:
    ///   - instructions: instructions of the transaction
    ///   - signers: the signers
    ///   - feePayer: the feePayer, usually is the first signer
    ///   - accountsCreationFee: estimated account creation fee
    ///   - recentBlockhash: recentBlockhash, can be fetched lately when the value is nil
    ///   - lamportsPerSignature: lamportsPerSignature, can be automatically fetched when the value is nil
    /// - Returns: information of a prepared transaction
    func prepareTransaction(
        instructions: [TransactionInstruction],
        signers: [Account],
        feePayer: PublicKey
    ) async throws -> PreparedTransaction
    
    /// Serialize PreparedTransaction for sending
    /// - Parameter preparedTransaction: a prepared transaction
    /// - Returns: Serialized transaction which is ready to be sent
    func serialize(
        preparedTransaction: PreparedTransaction
    ) throws -> String
}

extension SolanaBlockchainClient {
    func serialize(
        preparedTransaction: PreparedTransaction
    ) throws -> String {
        try preparedTransaction.serialize()
    }
}
