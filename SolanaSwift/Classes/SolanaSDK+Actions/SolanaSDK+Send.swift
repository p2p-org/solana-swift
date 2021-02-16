//
//  SolanaSDK+Send.swift
//  SolanaSwift
//
//  Created by Chung Tran on 25/01/2021.
//

import Foundation
import RxSwift

extension SolanaSDK {
    /**
        send SOL to another account.
     
        - Parameter to: publicKey to send to
        - Parameter amount: amount to send
    */
    public func sendSOL(
        to toPublicKey: String,
        amount: UInt64
    ) -> Single<TransactionID> {
        guard let account = self.accountStorage.account else {
            return .error(Error.unauthorized)
        }
        
        do {
            let fromPublicKey = account.publicKey
            let toPublicKey = try PublicKey(string: toPublicKey)
            
            var transaction = Transaction()
            transaction.message.add(
                instruction: SystemProgram.transferInstruction(
                    from: fromPublicKey,
                    to: toPublicKey,
                    lamports: amount
                )
            )
            
            return serializeTransaction(transaction, signers: [account])
                .flatMap {self.sendTransaction(serializedTransaction: $0)}
        } catch {
            return .error(error)
        }
    }
    
    /**
        send SPLTokens to another account.
     
        - Parameter to: publicKey to send to
        - Parameter amount: amount to send
    */
    public func sendSPLTokens(
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
            
            var transaction = Transaction()
            transaction.message.add(
                instruction: TokenProgram.transferInstruction(
                    tokenProgramId: .tokenProgramId,
                    source: fromPublicKey,
                    destination: toPublicKey,
                    owner: account.publicKey,
                    amount: amount
                )
            )
            return serializeTransaction(transaction, signers: [account])
                .flatMap {self.sendTransaction(serializedTransaction: $0)}
        } catch {
            return .error(error)
        }
    }
}
