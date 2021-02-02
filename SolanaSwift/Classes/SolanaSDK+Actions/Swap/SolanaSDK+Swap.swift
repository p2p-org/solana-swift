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
        pool: Pool? = nil,
        source: PublicKey,
        sourceMint: PublicKey,
        destination: PublicKey? = nil,
        destinationMint: PublicKey,
        slippage: Double,
        amount: UInt64
    ) -> Single<TransactionID> {
        // verify account
        guard let owner = account ?? accountStorage.account
        else {return .error(Error.accountNotFound)}
        
        // reuse variables
        var pool = pool
        
        // reduce pools
        var getPoolRequest: Single<Pool>
        if let pool = pool {
            getPoolRequest = .just(pool)
        } else {
            getPoolRequest = getSwapPools()
                .map {pools -> Pool in
                    // filter pool that match requirement
                    if let matchPool = pools.matchedPool(
                        sourceMint: sourceMint.base58EncodedString,
                        destinationMint: destinationMint.base58EncodedString
                    ) {
                        pool = matchPool
                        return matchPool
                    }
                    throw Error.other("Unsupported swapping tokens")
                }
        }
        
        // get pool
        return getPoolRequest
            .flatMap { pool -> Single<[Any]> in
                Single.zip([
                    self.getAccountInfoData(
                        account: pool.swapData.tokenAccountA.base58EncodedString,
                        tokenProgramId: .tokenProgramId
                    )
                        .map {$0 as Any},
                    
                    self.getMinimumBalanceForRentExemption(dataLength: UInt64(AccountInfo.BUFFER_LENGTH))
                        .map {$0 as Any}
                ])
            }
            .flatMap {params in
                guard let pool = pool,
                      let tokenABalance = UInt64(pool.tokenABalance?.amount ?? ""),
                      let tokenBBalance = UInt64(pool.tokenBBalance?.amount ?? "")
                else {return .error(Error.other("Balance amount is not valid"))}
                // get variables
                let tokenAInfo      = params[0] as! AccountInfo
                let minimumBalanceForRentExemption
                                    = params[1] as! UInt64
                
                // calculate mintAmountIn
                let estimatedAmount = Self.calculateSwapEstimatedAmount(
                    tokenABalance: tokenABalance,
                    tokenBBalance:  tokenBBalance,
                    inputAmount: amount
                )
                
                let minAmountIn = Self.calculateSwapMinimumReceiveAmount(
                    estimatedAmount: estimatedAmount,
                    slippage: slippage
                )
                
                // find account
                var source = source
                var destination = destination
                
                // form transaction
                var transaction = Transaction()
                var signers = [owner]
                
                // create fromToken if it is native
                if tokenAInfo.isNative {
                    let newAccount = try transaction.createAndInitializeAccount(
                        ownerPubkey: owner.publicKey,
                        tokenInputAmount: amount,
                        minimumBalanceForRentExemption: minimumBalanceForRentExemption,
                        inNetwork: self.network
                    )
                    
                    signers.append(newAccount)
                    
                    source = newAccount.publicKey
                }
                
                // check toToken
                let isMintBWSOL = destinationMint == .wrappedSOLMint
                if destination == nil {
                    // create toToken if it doesn't exist
                    let newAccount = try transaction.createAndInitializeAccount(
                        ownerPubkey: owner.publicKey,
                        tokenInputAmount: amount,
                        minimumBalanceForRentExemption: minimumBalanceForRentExemption,
                        inNetwork: self.network
                    )
                    
                    signers.append(newAccount)
                    
                    destination = newAccount.publicKey
                }
                
                // approve and swap
                transaction.approve(
                    tokenProgramId: .tokenProgramId,
                    account: source,
                    delegate: pool.authority,
                    owner: owner.publicKey,
                    amount: amount
                )
                
                transaction.swap(
                    swapProgramId: self.network.swapProgramId,
                    pool: pool,
                    userSource: source,
                    userDestination: destination!,
                    amount: amount,
                    minAmountIn: minAmountIn
                )
                
                // close redundant account
                let isNeedCloseAccount = tokenAInfo.isNative || isMintBWSOL
                var closingAccount: PublicKey!
                
                if tokenAInfo.isNative {
                    closingAccount = source
                } else if isMintBWSOL {
                    closingAccount = destination
                }
                
                if isNeedCloseAccount,
                   let closingAccount = closingAccount
                {
                    transaction.closeAccount(closingAccount, destination: owner.publicKey, owner: owner.publicKey)
                }
                
                return self.serializeTransaction(transaction, signers: signers)
            }
            .flatMap {self.sendTransaction(serializedTransaction: $0)}
    }
    
    // MARK: - Helpers
    public static func calculateSwapEstimatedAmount(
        tokenABalance: UInt64,
        tokenBBalance: UInt64,
        inputAmount: UInt64
    ) -> UInt64 {
        UInt64(BInt(tokenBBalance) * BInt(inputAmount) / (BInt(tokenABalance) + BInt(inputAmount)))
    }
    
    public static func calculateSwapMinimumReceiveAmount(
        estimatedAmount: UInt64,
        slippage: Double
    ) -> UInt64 {
        UInt64(Float64(estimatedAmount) * Float64(1 - slippage / 100))
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
