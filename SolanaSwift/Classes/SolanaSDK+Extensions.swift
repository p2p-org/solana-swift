//
//  SolanaSDK+Extensions.swift
//  SolanaSwift
//
//  Created by Chung Tran on 11/9/20.
//

import Foundation
import RxSwift

extension SolanaSDK {
    public func sendTokens(from fromPublicKey: String, to toPublicKey: String, amount: Int64) -> Single<String> {
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
                    instruction: SPLTokenProgram.transferInstruction(
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
        getMinimumBalanceForRentExemption(dataLength: AccountLayout.span)
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
                let createAccountInstruction = SPLTokenProgram.createAccountInstruction(
                    from: payer.publicKey,
                    toNewPubkey: newAccount.publicKey,
                    lamports: minBalance
                )
                
                let initializeAccountInstruction = SPLTokenProgram.initializeAccountInstruction(
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
    
    // MARK: - Swap
    public func swap(
        owner: Account,
        slippage: Double,
        tokenInputAmount: UInt64
    ) {
        let wrappedSOLMint = PublicKey.wrappedSOLMint
        let ownerPubkey = owner.publicKey
        let swapProgramId = PublicKey.swapProgramId
        let poolAddress = PublicKey.poolAddress
        
        var signers = [owner]
        
        // get pool info
        
        // forming transaction
        let transaction = Transaction()
        
    }
    
    // MARK: - Helpers
//    private func findAccountAddress(tokenMint: PublicKey) -> PublicKey {
//        // TODO: - findAccountAddress
//        return try! PublicKey(string: "7PECuw9WYABTpb19mGMwbq7ZDHnXcd1kTqXu1NuCP9o4")
//    }
//    
//    private func calculateAmount(
//        tokenABalance: UInt64,
//        tokenBBalance: UInt64,
//        slippage: Double,
//        inputAmount: UInt64
//    ) -> UInt64 {
//        let estimatedAmount = tokenBBalance * inputAmount / (tokenABalance + inputAmount)
//        return UInt64(Float64(estimatedAmount) * Float64(1 - slippage))
//    }
    
//    private func getPoolInfo(address: String) {
//        getAccountInfo(account: <#T##String#>)
//    }
}
