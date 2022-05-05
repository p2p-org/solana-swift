import Foundation

/// Default implementation of SolanaBlockchainClient
class BlockchainClient: SolanaBlockchainClient {
    func load() async throws {
        <#code#>
    }
    
    func update() async throws {
        <#code#>
    }
    
    func prepareTransaction(
        instructions: [TransactionInstruction],
        signers: [Account],
        feePayer: PublicKey
    ) async throws -> PreparedTransaction {
        var transaction = Transaction()
        transaction.instructions = instructions
        transaction.recentBlockhash = recentBlockhash
        transaction.feePayer = feePayer
        
        // calculate fee first
        let expectedFee = FeeAmount(
            transaction: try transaction.calculateTransactionFee(lamportsPerSignatures: lamportsPerSignature),
            accountBalances: accountsCreationFee
        )
        
        // resign transaction
        try transaction.sign(signers: signers)
        
        
        return .init(transaction: transaction, signers: signers, expectedFee: expectedFee)
    }
}
