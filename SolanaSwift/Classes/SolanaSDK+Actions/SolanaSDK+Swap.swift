//
//  SolanaSDK+Swap.swift
//  SolanaSwift
//
//  Created by Chung Tran on 21/01/2021.
//

import Foundation
import RxSwift

extension SolanaSDK {
    public func swap(
        owner: Account,
        fromToken tokenSource: PublicKey,
        toToken tokenDestination: PublicKey,
        slippage: Double,
        amount tokenInputAmount: UInt64,
        cluster network: String
    ) -> Single<TransactionID> {
        
        createSwapTransaction(
            owner: owner,
            fromToken: tokenSource,
            toToken: tokenDestination,
            slippage: slippage,
            amount: tokenInputAmount,
            network: network
        )
            .flatMap {
                self.sendTransaction(serializedTransaction: $0)
            }
    }
    
    public func createSwapTransaction(
        owner: Account,
        fromToken tokenSource: PublicKey,
        toToken tokenDestination: PublicKey,
        slippage: Double,
        amount tokenInputAmount: UInt64,
        network: String,
        recentBlockhash: String? = nil
    ) -> Single<String> {
        let ownerPubkey = owner.publicKey
        
        var tokenA: PublicKey!
        var tokenB: PublicKey!
        var mintA: PublicKey!
        var mintB: PublicKey!
        var minAmountIn: UInt64!
        
        var pool: Pool!
        
        // get pool info
        return getPoolInfo(address: PublicKey.poolAddress.base58EncodedString)
            // get balances
            .flatMap {newPool -> Single<[Any]> in
                // save pool
                pool = newPool
                
                // swap type
                tokenA = pool.swapData.tokenAccountA
                tokenB = pool.swapData.tokenAccountB
                mintA = pool.swapData.mintA
                mintB = pool.swapData.mintB
                if tokenSource != pool.swapData.tokenAccountA {
                    tokenA = pool.swapData.tokenAccountB
                    tokenB = pool.swapData.tokenAccountA
                    mintA = pool.swapData.mintB
                    mintB = pool.swapData.mintA
                }
                
                return Single.zip(
                    [
                        self.getTokenAccountBalance(pubkey: tokenA.base58EncodedString)
                            .map {$0 as Any},
                        self.getTokenAccountBalance(pubkey: tokenB.base58EncodedString)
                            .map {$0 as Any},
                        self.getAccountInfoData(account: tokenA.base58EncodedString, tokenProgramId: .tokenProgramId)
                            .map {$0 as Any},
                        self.getMinimumBalanceForRentExemption(dataLength: UInt64(AccountInfo.BUFFER_LENGTH))
                            .map {$0 as Any}
                    ]
                )
            }
            .flatMap {params in
                // form transaction
                var transaction = Transaction()
                var signers = [owner]
                
                // calculate balance
                let tokenABalance = params[0] as! TokenAccountBalance
                let tokenBBalance = params[1] as! TokenAccountBalance
                minAmountIn = self.calculateAmount(tokenABalance: UInt64(tokenABalance.amount)!, tokenBBalance:  UInt64(tokenBBalance.amount)!, slippage: slippage, inputAmount: tokenInputAmount)
                
                // account info
                let tokenAInfo = params[2] as! AccountInfo
                let minimumBalanceForRentExemption = params[3] as! UInt64
                
                var fromAccount: PublicKey!
                var toAccount: PublicKey!
                
                if tokenAInfo.isNative {
                    let newAccount = try transaction.createAndInitializeAccount(
                        ownerPubkey: ownerPubkey,
                        tokenInputAmount: tokenInputAmount,
                        minimumBalanceForRentExemption: minimumBalanceForRentExemption,
                        inNetwork: network
                    )
                    
                    signers.append(newAccount)
                    
                    fromAccount = newAccount.publicKey
                } else {
                    fromAccount = self.findAccountAddress(tokenMint: mintA)
                }
                
                toAccount = self.findAccountAddress(tokenMint: mintB)
                let isWrappedSol = mintB == .wrappedSOLMint
                
                if toAccount == nil {
                    let newAccount = try transaction.createAndInitializeAccount(
                        ownerPubkey: ownerPubkey,
                        tokenInputAmount: tokenInputAmount,
                        minimumBalanceForRentExemption: minimumBalanceForRentExemption,
                        inNetwork: network
                    )
                    
                    signers.append(newAccount)
                    
                    toAccount = newAccount.publicKey
                }
                
                // approve and swap
                transaction.approveAndSwap(fromAccount: fromAccount, owner: ownerPubkey, inPool: pool, poolSource: tokenA, poolDestination: tokenB, userDestination: toAccount, amount: tokenInputAmount, minimumAmountOut: minAmountIn)
                
                let isNeedCloseAccount = tokenAInfo.isNative || isWrappedSol
                var closingAccount: PublicKey!
                
                if tokenAInfo.isNative {
                    closingAccount = fromAccount
                } else if isWrappedSol {
                    closingAccount = toAccount
                }
                
                if isNeedCloseAccount,
                   let closingAccount = closingAccount
                {
                    transaction.closeAccount(closingAccount, destination: ownerPubkey, owner: ownerPubkey)
                }
                
                return self.serializeTransaction(transaction, recentBlockhash: recentBlockhash, signers: signers)
            }
    }
    
    // MARK: - Helpers
    private func findAccountAddress(tokenMint: PublicKey) -> PublicKey? {
        // TODO: - findAccountAddress
        return try! PublicKey(string: "7PECuw9WYABTpb19mGMwbq7ZDHnXcd1kTqXu1NuCP9o4")
    }

    private func calculateAmount(
        tokenABalance: UInt64,
        tokenBBalance: UInt64,
        slippage: Double,
        inputAmount: UInt64
    ) -> UInt64 {
        let estimatedAmount = tokenBBalance * inputAmount / (tokenABalance + inputAmount)
        return UInt64(Float64(estimatedAmount) * Float64(1 - slippage))
    }
    
    private func getPoolInfo(address: String) -> Single<Pool> {
        getAccountInfo(account: address, decodedTo: TokenSwapInfo.self)
            .map { info -> TokenSwapInfo in
                let swapInfo = info.data.value
                if let swapInfo = swapInfo {
                    return swapInfo
                }
                throw Error.other("Invalid data")
            }
            .flatMap { swapData in
                Single.zip([
                    self.getMintData(mintAddress: swapData.mintA, programId: PublicKey.tokenProgramId),
                    self.getMintData(mintAddress: swapData.mintB, programId: PublicKey.tokenProgramId),
                    self.getMintData(mintAddress: swapData.tokenPool, programId: PublicKey.tokenProgramId)
                ])
                .map { mintDatas in
                    guard let authority = mintDatas[2].mintAuthority else {
                        throw Error.other("Invalid mintAuthority")
                    }
                    return Pool(tokenAInfo: mintDatas[0], tokenBInfo: mintDatas[1], poolTokenMint: mintDatas[2], authority: authority, swapData: swapData)
                }
            }
    }
    
    private func getMintData(
        mintAddress: PublicKey,
        programId: PublicKey
    ) -> Single<Mint> {
        getAccountInfo(account: mintAddress.base58EncodedString, decodedTo: Mint.self)
            .map {
                if $0.owner != programId.base58EncodedString {
                    throw Error.other("Invalid mint owner")
                }
                
                if let data = $0.data.value {
                    return data
                }
                
                throw Error.other("Invalid data")
            }
    }
    
    private func getAccountInfoData(account: String, tokenProgramId: PublicKey) -> Single<AccountInfo> {
        getAccountInfo(account: account, decodedTo: AccountInfo.self)
            .map {
                if $0.owner != tokenProgramId.base58EncodedString {
                    throw Error.other("Invalid account owner")
                }
                if let info = $0.data.value {
                    return info
                }
                throw Error.other("Invalid data")
            }
    }
}
