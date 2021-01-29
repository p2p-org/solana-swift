//
//  TokenSwapInfo.swift
//  SolanaSwift
//
//  Created by Chung Tran on 21/01/2021.
//

import Foundation

extension SolanaSDK {
    public struct TokenSwapInfo: BufferLayout, Equatable, Hashable {
        // MARK: - Properties
        public let isInitialized: Bool
        public let nonce: UInt8
        public let tokenProgramId: PublicKey
        public let tokenAccountA: PublicKey
        public let tokenAccountB: PublicKey
        public let tokenPool: PublicKey
        public let mintA: PublicKey
        public let mintB: PublicKey
        public let feeAccount: PublicKey
        public let curveType: UInt8
        public let tradeFeeNumerator: UInt64
        public let tradeFeeDenominator: UInt64
        public let ownerTradeFeeNumerator: UInt64
        public let ownerTradeFeeDenominator: UInt64
        public let ownerWithdrawFeeNumerator: UInt64
        public let ownerWithdrawFeeDenominator: UInt64
        public let hostFeeNumerator: UInt64
        public let hostFeeDenominator: UInt64
        
        
        // MARK: - Initializer
        public init?(_ keys: [String: [UInt8]]) {
            guard let isInitialized = keys["isInitialized"]?.first,
                  let nonce = keys["nonce"]?.first,
                  let tokenProgramId = try? PublicKey(bytes: keys["tokenProgramId"]),
                  let tokenAccountA = try? PublicKey(bytes: keys["tokenAccountA"]),
                  let tokenAccountB = try? PublicKey(bytes: keys["tokenAccountB"]),
                  let tokenPool = try? PublicKey(bytes: keys["tokenPool"]),
                  let mintA = try? PublicKey(bytes: keys["mintA"]),
                  let mintB = try? PublicKey(bytes: keys["mintB"]),
                  let feeAccount = try? PublicKey(bytes: keys["feeAccount"]),
                  let curveType = keys["curveType"]?.first,
                  let tradeFeeNumerator = keys["tradeFeeNumerator"]?.toUInt64(),
                  let tradeFeeDenominator = keys["tradeFeeDenominator"]?.toUInt64(),
                  let ownerTradeFeeNumerator = keys["ownerTradeFeeNumerator"]?.toUInt64(),
                  let ownerTradeFeeDenominator = keys["ownerTradeFeeDenominator"]?.toUInt64(),
                  let ownerWithdrawFeeNumerator = keys["ownerWithdrawFeeNumerator"]?.toUInt64(),
                  let ownerWithdrawFeeDenominator = keys["ownerWithdrawFeeDenominator"]?.toUInt64(),
                  let hostFeeNumerator = keys["hostFeeNumerator"]?.toUInt64(),
                  let hostFeeDenominator = keys["hostFeeDenominator"]?.toUInt64()
            else {
                return nil
            }
            self.isInitialized = isInitialized == 1
            self.nonce = nonce
            self.tokenProgramId = tokenProgramId
            self.tokenAccountA = tokenAccountA
            self.tokenAccountB = tokenAccountB
            self.tokenPool = tokenPool
            self.mintA = mintA
            self.mintB = mintB
            self.feeAccount = feeAccount
            self.curveType = curveType
            self.tradeFeeNumerator = tradeFeeNumerator
            self.tradeFeeDenominator = tradeFeeDenominator
            self.ownerTradeFeeNumerator = ownerTradeFeeNumerator
            self.ownerTradeFeeDenominator = ownerTradeFeeDenominator
            self.ownerWithdrawFeeNumerator = ownerWithdrawFeeNumerator
            self.ownerWithdrawFeeDenominator = ownerWithdrawFeeDenominator
            self.hostFeeNumerator = hostFeeNumerator
            self.hostFeeDenominator = hostFeeDenominator
        }
        
        // MARK: - Layout
        public static func layout()  -> [(key: String?, length: Int)] {
            [
                (key: "isInitialized", length: 1),
                (key: "nonce", length: 1),
                (key: "tokenProgramId", length: PublicKey.LENGTH),
                (key: "tokenAccountA", length: PublicKey.LENGTH),
                (key: "tokenAccountB", length: PublicKey.LENGTH),
                (key: "tokenPool", length: PublicKey.LENGTH),
                (key: "mintA", length: PublicKey.LENGTH),
                (key: "mintB", length: PublicKey.LENGTH),
                (key: "feeAccount", length: PublicKey.LENGTH),
                (key: "curveType", length: 1),
                (key: "tradeFeeNumerator", length: 8),
                (key: "tradeFeeDenominator", length: 8),
                (key: "ownerTradeFeeNumerator", length: 8),
                (key: "ownerTradeFeeDenominator", length: 8),
                (key: "ownerWithdrawFeeNumerator", length: 8),
                (key: "ownerWithdrawFeeDenominator", length: 8),
                (key: "hostFeeNumerator", length: 8),
                (key: "hostFeeDenominator", length: 8)
            ]
        }
    }
}
