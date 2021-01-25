//
//  SolanaSDK+CreateTokenAccount.swift
//  SolanaSwift
//
//  Created by Chung Tran on 25/01/2021.
//

import Foundation
import RxSwift

extension SolanaSDK {
    public func getCreatingTokenAccountFee() -> Single<UInt64> {
        getMinimumBalanceForRentExemption(dataLength: AccountInfo.span)
    }

    public func createTokenAccount(mintAddress: String, in network: String) -> Single<(signature: String, newPubkey: String)> {
        guard let payer = self.accountStorage.account else {
            return .error(Error.publicKeyNotFound)
        }

        var newAccount: Account!
        return Single.zip(getRecentBlockhash(), getCreatingTokenAccountFee())
            .flatMap { (recentBlockhash, minBalance) in
                
                let mintAddress = try PublicKey(string: mintAddress)
                
                // create new account for token
                newAccount = try Account(network: network)
                
                // instructions
                let createAccountInstruction = SystemProgram.createAccountInstruction(
                    from: payer.publicKey,
                    toNewPubkey: newAccount.publicKey,
                    lamports: minBalance
                )
                
                let initializeAccountInstruction = TokenProgram.initializeAccountInstruction(
                    account: newAccount.publicKey,
                    mint: mintAddress,
                    owner: payer.publicKey
                )
                
                // forming transaction
                var transaction = Transaction()
                transaction.message.add(instruction: createAccountInstruction)
                transaction.message.add(instruction: initializeAccountInstruction)
                
                // serialize transaction
                return self.serializeTransaction(transaction, recentBlockhash: recentBlockhash, signers: [payer, newAccount])
            }
            .flatMap {
                self.sendTransaction(serializedTransaction: $0)
                    .map {($0, newAccount.publicKey.base58EncodedString)}
            }
    }
}
