import Foundation

/// Default implementation of SolanaBlockchainClient
public class BlockchainClient<APIClient: SolanaAPIClient>: SolanaBlockchainClient {
    public var apiClient: APIClient
    
    public init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    public func prepareTransaction(
        instructions: [TransactionInstruction],
        signers: [Account],
        feePayer: PublicKey,
        feeCalculator fc: FeeCalculator?
    ) async throws -> PreparedTransaction {
        // form transaction
        let transaction = Transaction(instructions: instructions, recentBlockhash: nil, feePayer: feePayer)
        
        // calculate fee first
        let feeCalculator: FeeCalculator
        if let fc = fc {
            feeCalculator = fc
        } else {
            let (lamportsPerSignature, minRentExemption) = try await (
                apiClient.getFees().feeCalculator?.lamportsPerSignature,
                apiClient.getMinimumBalanceForRentExemption(span: 165)
            )
            guard let lamportsPerSignature = lamportsPerSignature
            else {
                throw SolanaError.other("Fee calculator not found")
            }
            feeCalculator = DefaultFeeCalculator(lamportsPerSignature: lamportsPerSignature, minRentExemption: minRentExemption)
        }
        let expectedFee = try feeCalculator.calculateNetworkFee(transaction: transaction)
        
        // return formed transaction
        return .init(transaction: transaction, signers: signers, expectedFee: expectedFee)
    }
}
