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
        amount: UInt64,
        isSimulation: Bool = false
    ) -> Single<TransactionID> {
        // verify account
        guard let owner = account ?? accountStorage.account
        else {return .error(Error.unauthorized)}
        
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
                      let poolAuthority = pool.authority,
                      let estimatedAmount = pool.estimatedAmount(forInputAmount: amount),
                      let tokenBBalance = UInt64(pool.tokenBBalance?.amount ?? "")
                else {return .error(Error.other("Swap pool is not valid"))}
                // get variables
                let tokenAInfo      = params[0] as! AccountInfo
                let minimumBalanceForRentExemption
                                    = params[1] as! UInt64
                
                let minAmountIn = pool.minimumReceiveAmount(estimatedAmount: estimatedAmount, slippage: slippage)
                
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
                        mint: sourceMint,
                        balance: amount + minimumBalanceForRentExemption,
                        inNetwork: self.network
                    )
                    
                    signers.append(newAccount)
                    
                    source = newAccount.publicKey
                }
                
                // check toToken
                let isMintBWSOL = destinationMint == .wrappedSOLMint
                if destination == nil || isMintBWSOL {
                    // create toToken if it doesn't exist
                    let newAccount = try transaction.createAndInitializeAccount(
                        ownerPubkey: owner.publicKey,
                        mint: destinationMint,
                        balance: minimumBalanceForRentExemption,
                        inNetwork: self.network
                    )
                    
                    signers.append(newAccount)
                    
                    destination = newAccount.publicKey
                }
                
                // approve and swap
                transaction.approve(
                    tokenProgramId: .tokenProgramId,
                    account: source,
                    delegate: poolAuthority,
                    owner: owner.publicKey,
                    amount: amount
                )
                
                try transaction.swap(
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
                
                return self.serializeAndSend(transaction: transaction, signers: signers, isSimulation: isSimulation)
            }
    }
    
    // MARK: - Helpers
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
