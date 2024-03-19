import Foundation
import Task_retrying

/// BlockchainClient that prepares and serialises transaction to send to blockchain
public protocol SolanaBlockchainClient: AnyObject {
    /// APIClient for handling network requests
    var apiClient: SolanaAPIClient { get set }

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
        signers: [KeyPair],
        feePayer: PublicKey,
        feeCalculator: FeeCalculator?
    ) async throws -> PreparedTransaction

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
    ) async throws -> SimulationResult
}

public extension SolanaBlockchainClient {
    /// Send preparedTransaction
    /// - Parameter preparedTransaction: preparedTransaction to be sent
    /// - Returns: Transaction signature
    func sendTransaction(
        preparedTransaction: PreparedTransaction
    ) async throws -> String {
        try await Task.retrying(
            where: { $0.isEqualTo(.blockhashNotFound) },
            maxRetryCount: 3,
            retryDelay: 1,
            timeoutInSeconds: 60
        ) {
            let recentBlockhash = try await self.apiClient.getRecentBlockhash()
            let serializedTransaction = try self.signAndSerialize(
                preparedTransaction: preparedTransaction,
                recentBlockhash: recentBlockhash
            )
            return try await self.apiClient.sendTransaction(
                transaction: serializedTransaction,
                configs: RequestConfiguration(encoding: "base64")!
            )
        }
        .value
    }

    /// Simulate transaction (for testing purpose)
    /// - Parameter preparedTransaction: preparedTransaction to be simulated
    /// - Returns: The result of Simulation
    func simulateTransaction(
        preparedTransaction: PreparedTransaction
    ) async throws -> SimulationResult {
        let recentBlockhash = try await apiClient.getRecentBlockhash()
        let serializedTransaction = try signAndSerialize(
            preparedTransaction: preparedTransaction,
            recentBlockhash: recentBlockhash
        )
        return try await apiClient.simulateTransaction(
            transaction: serializedTransaction, configs: RequestConfiguration(
                commitment: "confirmed",
                encoding: "base64",
                replaceRecentBlockhash: true
            )!
        )
    }

    // MARK: - Helpers

    /// Sign and serialize transaction (for testing purpose)
    /// - Parameters:
    ///   - preparedTransaction: preparedTransaction
    ///   - recentBlockhash: recentBlockhash
    /// - Returns: serializedTransaction
    internal func signAndSerialize(
        preparedTransaction: PreparedTransaction,
        recentBlockhash: String
    ) throws -> String {
        var preparedTransaction = preparedTransaction
        preparedTransaction.transaction.recentBlockhash = recentBlockhash
        try preparedTransaction.sign()
        return try preparedTransaction.serialize()
    }
}
