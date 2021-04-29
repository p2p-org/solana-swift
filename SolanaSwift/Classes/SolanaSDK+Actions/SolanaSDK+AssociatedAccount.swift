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
        account: Account? = nil,
        tokenMint: PublicKey,
        isSimulation: Bool = false
    ) -> Single<TransactionID> {
        // get account
        guard let account = account ?? accountStorage.account else {
            return .error(Error.unauthorized)
        }
        
        
        // generate address
        do {
            let associatedAddress = try PublicKey.associatedTokenAddress(
                walletAddress: account.publicKey,
                tokenMintAddress: tokenMint
            )
            
            // create instruction
            let instruction = AssociatedTokenProgram
                .createAssociatedTokenAccountInstruction(
                    associatedProgramId: .splAssociatedTokenAccountProgramId,
                    programId: .tokenProgramId,
                    mint: tokenMint,
                    associatedAccount: associatedAddress,
                    owner: account.publicKey,
                    payer: account.publicKey
                )
            
            // send transaction
            return serializeAndSend(
                instructions: [instruction],
                signers: [account],
                isSimulation: isSimulation
            )
            
        } catch {
            return .error(error)
        }
    }
}
