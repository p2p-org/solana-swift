//
//  SolanaSDK+Pool.swift
//  SolanaSwift
//
//  Created by Chung Tran on 26/01/2021.
//

import Foundation
import RxSwift

extension SolanaSDK {
    public func getPools(swapProgramId: String) -> Single<[Pool]> {
        getProgramAccounts(publicKey: swapProgramId, decodedTo: TokenSwapInfo.self)
            .map {$0.compactMap {$0.account.data.value}}
            .flatMap {
                Single.zip(
                    $0.compactMap {self.getPoolInfo(swapData: $0)}
                )
            }
    }
    
    func getPoolInfo(address: String) -> Single<Pool> {
        return getAccountInfo(account: address, decodedTo: TokenSwapInfo.self)
            .flatMap { info in
                let swapInfo = info.data.value
                if let swapInfo = swapInfo {
                    return self.getPoolInfo(swapData: swapInfo)
                }
                throw Error.other("Invalid data")
            }
    }
    
    func getPoolInfo(swapData: TokenSwapInfo) -> Single<Pool> {
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
