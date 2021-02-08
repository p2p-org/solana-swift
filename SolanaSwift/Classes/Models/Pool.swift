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
        
        public func amountInOtherToken(
            forInputAmount inputAmount: UInt64,
            includeFees: Bool
        ) -> Decimal? {
            guard let tokenABalance = tokenABalance?.amountInUInt64,
                  let tokenBBalance = tokenBBalance?.amountInUInt64
            else {return nil}
            let feeRatio = Decimal(swapData.tradeFeeNumerator) / Decimal(swapData.tradeFeeDenominator)
            let invariant = BInt(tokenABalance) * BInt(tokenBBalance)
            let newFromAmountInPool = BInt(tokenABalance) + BInt(inputAmount)
            let newToAmountInPool = invariant / newFromAmountInPool
            let grossToAmount = BInt(tokenBBalance) - newToAmountInPool
            
            let grossToAmountDecimal = Decimal(string: grossToAmount.asString(withBase: 10)) ?? 0
            
            let fees = includeFees ? grossToAmountDecimal * feeRatio: Decimal(0)
            return grossToAmountDecimal - fees
        }
        
        public func fee(forInputAmount inputAmount: UInt64) -> Double? {
            guard let swappedAmountWithFee = amountInOtherToken(forInputAmount: inputAmount, includeFees: true),
                  let swappedAmountWithoutFee = amountInOtherToken(forInputAmount: inputAmount, includeFees: false)
            else {
                return nil
            }
            let fee = swappedAmountWithoutFee - swappedAmountWithFee
            let feeInDouble = NSDecimalNumber(decimal:fee).doubleValue
            return feeInDouble * pow(10, -Double(tokenBInfo.decimals))
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
