import Foundation

/// Default implementation of SolanaBlockchainClient
public class BlockchainClient<APIClient: SolanaAPIClient>: SolanaBlockchainClient {
    public var feeCalculator: FeeCalculator
    public var apiClient: APIClient
    
    public init(
        apiClient: APIClient,
        feeCalculator: FeeCalculator
    ) {
        self.apiClient = apiClient
        self.feeCalculator = feeCalculator
    }
    
    public func prepareTransaction(
        instructions: [TransactionInstruction],
        signers: [Account],
        feePayer: PublicKey
    ) async throws -> PreparedTransaction {
        // get recent blockhash
        let recentBlockhash = try await apiClient.getRecentBlockhash()
        
        // form transaction
        var transaction = Transaction(instructions: instructions, recentBlockhash: recentBlockhash, feePayer: feePayer)
        
        // calculate fee first
        let expectedFee = try feeCalculator.calculateNetworkFee(transaction: transaction)
        
        // resign transaction
        try transaction.sign(signers: signers)
        
        // return formed transaction
        return .init(transaction: transaction, signers: signers, expectedFee: expectedFee)
    }
}
