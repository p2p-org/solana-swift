//
//  File.swift
//  
//
//  Created by Chung Tran on 04/05/2022.
//

import Foundation

class BlockchainClient: SolanaBlockchainClient {
    func prepareTransaction(
        instructions: [TransactionInstruction],
        signers: [Account],
        feePayer: PublicKey,
        accountsCreationFee: Lamports,
        recentBlockhash: String,
        lamportsPerSignature: Lamports
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
