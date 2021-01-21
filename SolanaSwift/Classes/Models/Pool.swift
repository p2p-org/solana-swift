//
//  Pool.swift
//  SolanaSwift
//
//  Created by Chung Tran on 21/01/2021.
//

import Foundation

extension SolanaSDK {
    struct Pool {
        let tokenAInfo: Mint
        let tokenBInfo: Mint
        let poolTokenMint: Mint
        let authority: PublicKey
        let swapData: TokenSwapInfo
    }
}
