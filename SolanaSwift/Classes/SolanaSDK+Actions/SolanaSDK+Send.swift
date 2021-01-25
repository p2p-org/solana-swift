//
//  SolanaSDK+Send.swift
//  SolanaSwift
//
//  Created by Chung Tran on 25/01/2021.
//

import Foundation
import RxSwift

extension SolanaSDK {
    public func sendTokens(
        from fromPublicKey: String,
        to toPublicKey: String,
        amount: UInt64
    ) -> Single<TransactionID> {
        guard let account = self.accountStorage.account else {
            return .error(Error.publicKeyNotFound)
        }
        
        do {
            let fromPublicKey = try PublicKey(string: fromPublicKey)
            let toPublicKey = try PublicKey(string: toPublicKey)
            return createSendTransaction(from: fromPublicKey, to: toPublicKey, amount: amount, signer: account)
        } catch {
            return .error(error)
        }
    }
    
    public func createSendTransaction(
        from fromPublicKey: PublicKey,
        to toPublicKey: PublicKey,
        amount: UInt64,
        signer: Account,
        recentBlockhash: String? = nil
    ) -> Single<String> {
        var transaction = Transaction()
        transaction.message.add(
            instruction: SystemProgram.transferInstruction(
                from: fromPublicKey,
                to: toPublicKey,
                lamports: amount
            )
        )
        
        return serializeTransaction(transaction, recentBlockhash: recentBlockhash, signers: [signer])
    }
}
