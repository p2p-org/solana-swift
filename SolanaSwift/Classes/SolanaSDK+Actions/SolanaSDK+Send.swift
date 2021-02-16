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
            return .error(Error.unauthorized)
        }
        
        do {
            let fromPublicKey = try PublicKey(string: fromPublicKey)
            let toPublicKey = try PublicKey(string: toPublicKey)
            
            // Send SOL
            if fromPublicKey == account.publicKey {
                return sendSOL(account: account, from: fromPublicKey, to: toPublicKey, amount: amount)
            }
                
            // Send Tokens
            return sendSPLTokens(account: account, from: fromPublicKey, to: toPublicKey, amount: amount)
        } catch {
            return .error(error)
        }
    }
    
    private func sendSOL(
        account: SolanaSDK.Account,
        from fromPublicKey: PublicKey,
        to toPublicKey: PublicKey,
        amount: UInt64
    ) -> Single<TransactionID> {
        createSendTransaction(from: fromPublicKey, to: toPublicKey, amount: amount, signer: account)
            .flatMap {self.sendTransaction(serializedTransaction: $0)}
    }
    
    private func sendSPLTokens(
        account: SolanaSDK.Account,
        from fromPublicKey: PublicKey,
        to toPublicKey: PublicKey,
        amount: UInt64
    ) -> Single<TransactionID> {
        fatalError()
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
        
        let serializedTransaction = serializeTransaction(transaction, recentBlockhash: recentBlockhash, signers: [signer])
        return serializedTransaction
    }
}
