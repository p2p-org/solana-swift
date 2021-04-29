//
//  SolanaSDK+AssociatedAccount.swift
//  SolanaSwift
//
//  Created by Chung Tran on 29/04/2021.
//

import Foundation
import RxSwift

extension SolanaSDK {
    public func createAssociatedTokenAccount(
        for owner: PublicKey,
        tokenMint: PublicKey,
        payer: Account? = nil,
        isSimulation: Bool = false
    ) -> Single<TransactionID> {
        // get account
        guard let payer = payer ?? accountStorage.account else {
            return .error(Error.unauthorized)
        }
        
        // generate address
        do {
            let associatedAddress = try PublicKey.associatedTokenAddress(
                walletAddress: owner,
                tokenMintAddress: tokenMint
            )
            
            // create instruction
            let instruction = AssociatedTokenProgram
                .createAssociatedTokenAccountInstruction(
                    associatedProgramId: .splAssociatedTokenAccountProgramId,
                    programId: .tokenProgramId,
                    mint: tokenMint,
                    associatedAccount: associatedAddress,
                    owner: owner,
                    payer: payer.publicKey
                )
            
            // send transaction
            return serializeAndSend(
                instructions: [instruction],
                signers: [payer],
                isSimulation: isSimulation
            )
            
        } catch {
            return .error(error)
        }
    }
}
