//
//  Pool.swift
//  SolanaSwift
//
//  Created by Chung Tran on 21/01/2021.
//

import Foundation

extension SolanaSDK {
    public struct Pool: Hashable {
        public let address: PublicKey
        public let tokenAInfo: Mint
        public let tokenBInfo: Mint
        public let poolTokenMint: Mint
        public let authority: PublicKey
        public let swapData: TokenSwapInfo
        public var tokenABalance: TokenAccountBalance?
        public var tokenBBalance: TokenAccountBalance?
    }
}
