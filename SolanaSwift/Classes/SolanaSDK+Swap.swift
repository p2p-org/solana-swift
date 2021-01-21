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
        amount tokenInputAmount: UInt64
    ) {
        let wrappedSOLMint = PublicKey.wrappedSOLMint
        let ownerPubkey = owner.publicKey
        let swapProgramId = PublicKey.swapProgramId
        let poolAddress = PublicKey.poolAddress
        
        var signers = [owner]
        
        // get pool info
        getPoolInfo(address: poolAddress.base58EncodedString)
            // get balances
            .flatMap {pool -> Single<UInt64> in
                // swap type
                var tokenA = pool.swapData.tokenAccountA
                var tokenB = pool.swapData.tokenAccountB
                var mintA = pool.swapData.mintA
                var mintB = pool.swapData.mintB
                //                var isSourceEqToPoolTokenAccountA = true
                if tokenSource != pool.swapData.tokenAccountA {
                    tokenA = pool.swapData.tokenAccountB
                    tokenB = pool.swapData.tokenAccountA
                    mintA = pool.swapData.mintB
                    mintB = pool.swapData.mintA
                    //                    isSourceEqToPoolTokenAccountA = false
                }
                return Single.zip(
                    [
                        self.getTokenAccountBalance(pubkey: tokenA!.base58EncodedString),
                        self.getTokenAccountBalance(pubkey: tokenB!.base58EncodedString)
                    ]
                )
                .map {balances in
                    self.calculateAmount(tokenABalance: UInt64(balances.first!.amount)!, tokenBBalance:  UInt64(balances.last!.amount)!, slippage: slippage, inputAmount: tokenInputAmount)
                }
            }
        
        // forming transaction
        let transaction = Transaction()
        
    }
    
    // MARK: - Helpers
    //    private func findAccountAddress(tokenMint: PublicKey) -> PublicKey {
    //        // TODO: - findAccountAddress
    //        return try! PublicKey(string: "7PECuw9WYABTpb19mGMwbq7ZDHnXcd1kTqXu1NuCP9o4")
    //    }
    //
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
                if let swapInfo = swapInfo, swapInfo.mintA != nil, swapInfo.mintB != nil, swapInfo.tokenPool != nil
                {
                    return swapInfo
                }
                throw Error.other("Invalid data")
            }
            .flatMap { swapData in
                Single.zip([
                    self.getMintData(mintAddress: swapData.mintA!, programId: PublicKey.tokenProgramId),
                    self.getMintData(mintAddress: swapData.mintB!, programId: PublicKey.tokenProgramId),
                    self.getMintData(mintAddress: swapData.tokenPool!, programId: PublicKey.tokenProgramId)
                ])
                .map { mintDatas in
                    guard let authority = mintDatas[2].mintAuthority else {
                        throw Error.other("Invalid mintAuthority")
                    }
                    return Pool(tokenAInfo: mintDatas[0], tokenBInfo: mintDatas[1], poolTokenMint: mintDatas[2], authority: authority, swapData: swapData)
                }
            }
        
        //            .flat
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
}
