//
//  Pool.swift
//  SolanaSwift
//
//  Created by Chung Tran on 21/01/2021.
//

import Foundation

extension SolanaSDK {
    public struct Pool: Hashable, Codable {
        public let address: PublicKey
        public var tokenAInfo: Mint
        public var tokenBInfo: Mint
        public let poolTokenMint: Mint
        public var swapData: TokenSwapInfo
        public var tokenABalance: TokenAccountBalance?
        public var tokenBBalance: TokenAccountBalance?
        
        public var fee: Double {
            Double(swapData.tradeFeeNumerator) / Double(swapData.tradeFeeDenominator) * 100
        }
        
        public var authority: PublicKey? {
            poolTokenMint.mintAuthority
        }
        
        public func estimatedAmount(forInputAmount inputAmount: UInt64) -> UInt64?
        {
            guard let tokenABalance = tokenABalance?.amountInUInt64,
                  let tokenBBalance = tokenBBalance?.amountInUInt64
            else {return nil}
            return UInt64(BInt(tokenBBalance) * BInt(inputAmount) / (BInt(tokenABalance) + BInt(inputAmount)))
        }
        
        public func minimumReceiveAmount(
            estimatedAmount: UInt64,
            slippage: Double
        ) -> UInt64 {
            UInt64(Float64(estimatedAmount) * Float64(1 - slippage / 100))
        }
    }
}

extension Array where Element == SolanaSDK.Pool {
    public func matchedPool(sourceMint: String?, destinationMint: String?) -> SolanaSDK.Pool?
    {
        first(where: {
            ($0.swapData.mintA.base58EncodedString == sourceMint && $0.swapData.mintB.base58EncodedString == destinationMint) ||
                ($0.swapData.mintB.base58EncodedString == sourceMint && $0.swapData.mintA.base58EncodedString == destinationMint)
        })
        .map { pool in
            var pool = pool
            if (pool.swapData.mintB.base58EncodedString == sourceMint && pool.swapData.mintA.base58EncodedString == destinationMint)
            {
                swap(&pool.swapData.tokenAccountA, &pool.swapData.tokenAccountB)
                swap(&pool.swapData.mintA, &pool.swapData.mintB)
                swap(&pool.tokenABalance, &pool.tokenBBalance)
                swap(&pool.tokenAInfo, &pool.tokenBInfo)
            }
            return pool
        }
    }
}
