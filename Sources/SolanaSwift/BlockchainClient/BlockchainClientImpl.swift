//
//  File.swift
//  
//
//  Created by Chung Tran on 04/05/2022.
//

import Foundation

class BlockchainClientImpl: BlockchainClient {
    func prepareTransaction(
        instructions: [TransactionInstruction],
        signers: [Account],
        feePayer: PublicKey,
        accountsCreationFee: Lamports,
        recentBlockhash: String?,
        lamportsPerSignature: Lamports?
    ) async throws -> PreparedTransaction {
        fatalError("implementing")
    }
}
