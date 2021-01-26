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
        account: Account? = nil,
        tokenA: PublicKey,
        mintA: PublicKey,
        tokenB: PublicKey? = nil,
        mintB: PublicKey,
        slippage: Double,
        amount: UInt64
    ) -> Single<TransactionID> {
        // verify account
        guard let owner = account ?? accountStorage.account
        else {return .error(Error.accountNotFound)}
        
        // reuse variables
        var pool: Pool!
        
        // get pool
        return getSwapPools()
            .map {pools -> Pool in
                // filter pool that match requirement
                if let matchPool = pools.first(where: {$0.swapData.mintA == mintA && $0.swapData.mintB == mintB})
                {
                    pool = matchPool
                    return pool
                }
                throw Error.other("Unsupported swapping tokens")
            }
            .flatMap { matchedPool -> Single<[Any]> in
                // get balance for tokenA
                var singles = [Single<Any>]()
                singles.append(
                    self.getTokenAccountBalance(pubkey: tokenA.base58EncodedString)
                        .map {UInt64($0.amount)}
                        .map {$0 as Any}
                )
                
                // get balance for tokenB, return 0 if tokenB does not exist
                if let tokenB = tokenB {
                    singles.append(
                        self.getTokenAccountBalance(pubkey: tokenB.base58EncodedString)
                            .map {UInt64($0.amount)}
                            .map {$0 as Any}
                    )
                } else {
                    singles.append(
                        Single<UInt64>.just(0)
                            .map {$0 as Any}
                    )
                }
                
                // get account info data and minimun balance for rent exemption
                singles += [
                    self.getAccountInfoData(account: tokenA.base58EncodedString, tokenProgramId: .tokenProgramId)
                        .map {$0 as Any},
                    self.getMinimumBalanceForRentExemption(dataLength: UInt64(AccountInfo.BUFFER_LENGTH))
                        .map {$0 as Any}
                ]
                
                return Single.zip(singles)
            }
            .flatMap {params in
                // get variables
                let tokenABalance   = params[0] as! UInt64
                let tokenBBalance   = params[1] as! UInt64
                let tokenAInfo      = params[2] as! AccountInfo
                let minimumBalanceForRentExemption
                                    = params[3] as! UInt64
                
                // form transaction
                var transaction = Transaction()
                var signers = [owner]
                
                // calculate mintAmountIn
                let minAmountIn = self.calculateAmount(
                    tokenABalance: tokenABalance,
                    tokenBBalance:  tokenBBalance,
                    slippage: slippage,
                    inputAmount: amount
                )
                
                // find account
                var fromAccount = tokenA
                var toAccount = tokenB
                
                // create fromToken if it is native
                if tokenAInfo.isNative {
                    let newAccount = try transaction.createAndInitializeAccount(
                        ownerPubkey: owner.publicKey,
                        tokenInputAmount: amount,
                        minimumBalanceForRentExemption: minimumBalanceForRentExemption,
                        inNetwork: self.network
                    )
                    
                    signers.append(newAccount)
                    
                    fromAccount = newAccount.publicKey
                }
                
                // check toToken
                let isMintBWSOL = mintB == .wrappedSOLMint
                if toAccount == nil {
                    // create toToken if it doesn't exist
                    let newAccount = try transaction.createAndInitializeAccount(
                        ownerPubkey: owner.publicKey,
                        tokenInputAmount: amount,
                        minimumBalanceForRentExemption: minimumBalanceForRentExemption,
                        inNetwork: self.network
                    )
                    
                    signers.append(newAccount)
                    
                    toAccount = newAccount.publicKey
                }
                
                // approve and swap
                transaction.approve(
                    tokenProgramId: .tokenProgramId,
                    account: fromAccount,
                    delegate: pool.authority,
                    owner: owner.publicKey,
                    amount: amount
                )
                
                transaction.swap(
                    swapProgramId: self.network.swapProgramId,
                    pool: pool,
                    userSource: fromAccount,
                    userDestination: toAccount!,
                    amount: amount,
                    minAmountIn: minAmountIn
                )
                
                // close redundant account
                let isNeedCloseAccount = tokenAInfo.isNative || isMintBWSOL
                var closingAccount: PublicKey!
                
                if tokenAInfo.isNative {
                    closingAccount = fromAccount
                } else if isMintBWSOL {
                    closingAccount = toAccount
                }
                
                if isNeedCloseAccount,
                   let closingAccount = closingAccount
                {
                    transaction.closeAccount(closingAccount, destination: owner.publicKey, owner: owner.publicKey)
                }
                
                return self.serializeTransaction(transaction, signers: signers)
            }
    }
    
    // MARK: - Helpers
    private func calculateAmount(
        tokenABalance: UInt64,
        tokenBBalance: UInt64,
        slippage: Double,
        inputAmount: UInt64
    ) -> UInt64 {
        let estimatedAmount = tokenBBalance * inputAmount / (tokenABalance + inputAmount)
        return UInt64(Float64(estimatedAmount) * Float64(1 - slippage))
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
