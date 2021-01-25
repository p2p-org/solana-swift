//
//  SolanaSDK+Extensions.swift
//  SolanaSwift
//
//  Created by Chung Tran on 11/9/20.
//

import Foundation
import RxSwift

extension SolanaSDK {
    // MARK: - Send tokens
    public func sendTokens(from fromPublicKey: String, to toPublicKey: String, amount: Int64) -> Single<TransactionID> {
        getRecentBlockhash()
            .flatMap { recentBlockhash in
                guard let account = self.accountStorage.account else {
                    throw Error.publicKeyNotFound
                }
                let fromPublicKey = try PublicKey(string: fromPublicKey)
                let toPublicKey = try PublicKey(string: toPublicKey)
                let signer = account
                
                var transaction = Transaction()
                transaction.message.add(
                    instruction: SystemProgram.transferInstruction(
                        from: fromPublicKey,
                        to: toPublicKey,
                        lamports: UInt64(amount)
                    )
                )
                transaction.message.recentBlockhash = recentBlockhash
                try transaction.sign(signers: [signer])
                guard let serializedTransaction = try transaction.serialize().toBase64() else {
                    throw Error.other("Could not serialize transaction")
                }
                return self.sendTransaction(serializedTransaction: serializedTransaction)
            }
    }
    
    public func getCreatingTokenAccountFee() -> Single<UInt64> {
        getMinimumBalanceForRentExemption(dataLength: AccountInfo.span)
    }

    public func createTokenAccount(mintAddress: String, in network: String) -> Single<(signature: String, newPubkey: String)> {
        guard let payer = self.accountStorage.account else {
            return .error(Error.publicKeyNotFound)
        }

        return Single.zip(getRecentBlockhash(), getCreatingTokenAccountFee())
            .flatMap { (recentBlockhash, minBalance) in
                
                let mintAddress = try PublicKey(string: mintAddress)
                
                // create new account for token
                let newAccount = try Account(network: network)
                
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
                transaction.message.recentBlockhash = recentBlockhash
                try transaction.sign(signers: [payer, newAccount])
                
                guard let serializedTransaction = try transaction.serialize().toBase64() else {
                    throw Error.other("Could not serialize transaction")
                }
                return self.sendTransaction(serializedTransaction: serializedTransaction)
                    .map {($0, newAccount.publicKey.base58EncodedString)}
            }
    }
}
