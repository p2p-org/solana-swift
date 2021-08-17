//
//  Pool.swift
//  SolanaSwift
//
//  Created by Chung Tran on 21/01/2021.
//

import Foundation

extension SolanaSDK {
    public struct Pool: Hashable, Codable {
        // MARK: - Constants
        public static var feeCompensationPoolDefaultSlippage: Double = 0.01
        
        // MARK: - Properties
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
        
        // MARK: - Calculations
        public func estimatedAmount(
            forInputAmount inputAmount: Lamports,
            includeFees: Bool
        ) -> Lamports? {
            guard let tokenABalance = tokenABalance?.amountInUInt64,
                  let tokenBBalance = tokenBBalance?.amountInUInt64
            else {return nil}
            
            let i = BInt(inputAmount)
            
            let b = BInt(tokenBBalance)
            let a = BInt(tokenABalance)
            let d = BInt(swapData.tradeFeeDenominator)
            let n = includeFees ? BInt(swapData.tradeFeeNumerator) : 0
            
            let numerator = b * i * (d - n)
            let denominator = (a + i) * d
            
            if denominator == 0 {
                return nil
            }
            
            return Lamports(numerator / denominator)
        }
        
        public func inputAmount(
            forEstimatedAmount estimatedAmount: Lamports,
            includeFees: Bool
        ) -> Lamports? {
            guard let tokenABalance = tokenABalance?.amountInUInt64,
                  let tokenBBalance = tokenBBalance?.amountInUInt64
            else {return nil}
            
            let e = BInt(estimatedAmount)
            
            let b = BInt(tokenBBalance)
            let a = BInt(tokenABalance)
            let d = BInt(swapData.tradeFeeDenominator)
            let n = includeFees ? BInt(swapData.tradeFeeNumerator) : 0
            
            let numerator = e * a * d
            let denominator = b * (d - n) - e * d
            
            if denominator == 0 {
                return nil
            }
            
            return Lamports(numerator / denominator)
        }
        
        public func inputAmount(
            forMinimumReceiveAmount minimumReceiveAmount: Lamports,
            slippage: Double,
            roundRules: FloatingPointRoundingRule? = nil,
            includeFees: Bool,
            replaceZeroWithMinimum: Bool = false
        ) -> Lamports? {
            guard let tokenABalance = tokenABalance?.amountInUInt64,
                  let tokenBBalance = tokenBBalance?.amountInUInt64
            else {return nil}
            
            let e = BInt(minimumReceiveAmount)
            
            let b = BInt(tokenBBalance)
            let a = BInt(tokenABalance)
            let d = BInt(swapData.tradeFeeDenominator)
            let n = includeFees ? BInt(swapData.tradeFeeNumerator) : 0
            
            let numerator = e * a * d
            let denominator = b * (d - n) - e * d
            
            if denominator == 0 {
                return nil
            }
            
            var float = Float64(numerator / denominator) * Float64(1 + slippage)
            if let rule = roundRules {
                float.round(rule)
            }
            
            let lamport = Lamports(float)
            
            if lamport == 0 && replaceZeroWithMinimum {
                return 1
            }
            return lamport
        }
        
        public func minimumReceiveAmount(
            fromInputAmount inputAmount: Lamports,
            slippage: Double,
            includesFees: Bool
        ) -> Lamports? {
            guard let estimatedAmount = estimatedAmount(forInputAmount: inputAmount, includeFees: includesFees)
            else {return nil}
            
            return Lamports(Float64(estimatedAmount) * Float64(1 - slippage))
        }
        
        public func fee(forInputAmount inputAmount: Double) -> Double? {
            guard let tokenABalance = tokenABalance?.amountInUInt64,
                  let tokenBBalance = tokenBBalance?.amountInUInt64
            else {return nil}
            
            let inputAmount = inputAmount.toLamport(decimals: tokenAInfo.decimals)
            
            let i = BInt(inputAmount)
            
            let b = BInt(tokenBBalance)
            let a = BInt(tokenABalance)
            let d = BInt(swapData.tradeFeeDenominator)
            let n = BInt(swapData.tradeFeeNumerator)
            
            let numerator = b * i * n
            let denominator = (a + i) * d
            
            if denominator == 0 {
                return nil
            }
            
            return Lamports(numerator / denominator).convertToBalance(decimals: tokenBInfo.decimals)
        }
        
        // MARK: - Helpers
        var reversedPool: Pool {
            var pool = self
            Swift.swap(&pool.swapData.tokenAccountA, &pool.swapData.tokenAccountB)
            Swift.swap(&pool.swapData.mintA, &pool.swapData.mintB)
            Swift.swap(&pool.tokenABalance, &pool.tokenBBalance)
            Swift.swap(&pool.tokenAInfo, &pool.tokenBInfo)
            return pool
        }
        
        public var isValid: Bool {
            authority != nil &&
            swapData.mintA != swapData.mintB &&
                (tokenABalance?.amountInUInt64 ?? 0) > 0 &&
                (tokenBBalance?.amountInUInt64 ?? 0) > 0
        }
    }
}

extension Array where Element == SolanaSDK.Pool {
    public func getMatchedPools(sourceMint: String?, destinationMint: String?) -> [SolanaSDK.Pool] {
        filter {
            ($0.swapData.mintA.base58EncodedString == sourceMint && $0.swapData.mintB.base58EncodedString == destinationMint) ||
                ($0.swapData.mintB.base58EncodedString == sourceMint && $0.swapData.mintA.base58EncodedString == destinationMint)
        }
        .map { pool in
            if (pool.swapData.mintB.base58EncodedString == sourceMint && pool.swapData.mintA.base58EncodedString == destinationMint)
            {
                return pool.reversedPool
            }
            return pool
        }
    }
    
    public func getPools(mintA: String) -> [SolanaSDK.Pool] {
        filter {
            $0.swapData.mintA.base58EncodedString == mintA ||
                $0.swapData.mintB.base58EncodedString == mintA
        }
        .map {
            if $0.swapData.mintB.base58EncodedString == mintA {
                return $0.reversedPool
            }
            return $0
        }
    }
    
    public func getPools(mintB: String) -> [SolanaSDK.Pool] {
        filter {
            $0.swapData.mintA.base58EncodedString == mintB ||
                $0.swapData.mintB.base58EncodedString == mintB
        }
        .map {
            if $0.swapData.mintA.base58EncodedString == mintB {
                return $0.reversedPool
            }
            return $0
        }
    }
    
}
