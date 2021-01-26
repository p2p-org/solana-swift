//
//  Pool.swift
//  SolanaSwift
//
//  Created by Chung Tran on 21/01/2021.
//

import Foundation

extension SolanaSDK {
    public struct Pool {
        public let tokenAInfo: Mint
        public let tokenBInfo: Mint
        public let poolTokenMint: Mint
        public let authority: PublicKey
        public let swapData: TokenSwapInfo
    }
}
