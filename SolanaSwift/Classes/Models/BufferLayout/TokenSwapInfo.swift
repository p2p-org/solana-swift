//
//  TokenSwapInfo.swift
//  SolanaSwift
//
//  Created by Chung Tran on 21/01/2021.
//

import Foundation

extension SolanaSDK {
    public struct TokenSwapInfo: BufferLayout {
        // MARK: - Properties
        public let isInitialized: Bool?
        public let nonce: UInt8?
        public let tokenProgramId: PublicKey?
        public let tokenAccountA: PublicKey?
        public let tokenAccountB: PublicKey?
        public let tokenPool: PublicKey?
        public let mintA: PublicKey?
        public let mintB: PublicKey?
        public let feeAccount: PublicKey?
        public let curveType: UInt8?
        public let tradeFeeNumerator: UInt64?
        public let tradeFeeDenominator: UInt64?
        public let ownerTradeFeeNumerator: UInt64?
        public let ownerTradeFeeDenominator: UInt64?
        public let ownerWithdrawFeeNumerator: UInt64?
        public let ownerWithdrawFeeDenominator: UInt64?
        public let hostFeeNumerator: UInt64?
        public let hostFeeDenominator: UInt64?
        
        
        // MARK: - Initializer
        public init?(_ keys: [String: [UInt8]]) {
            self.isInitialized = keys["isInitialized"]?.first == 1
            self.nonce = keys["nonce"]?.first
            self.tokenProgramId = try? PublicKey(bytes: keys["tokenProgramId"])
            self.tokenAccountA = try? PublicKey(bytes: keys["tokenAccountA"])
            self.tokenAccountB = try? PublicKey(bytes: keys["tokenAccountB"])
            self.tokenPool = try? PublicKey(bytes: keys["tokenPool"])
            self.mintA = try? PublicKey(bytes: keys["mintA"])
            self.mintB = try? PublicKey(bytes: keys["mintB"])
            self.feeAccount = try? PublicKey(bytes: keys["feeAccount"])
            self.curveType = keys["curveType"]?.first
            self.tradeFeeNumerator = keys["tradeFeeNumerator"]?.toUInt64()
            self.tradeFeeDenominator = keys["tradeFeeDenominator"]?.toUInt64()
            self.ownerTradeFeeNumerator = keys["ownerTradeFeeNumerator"]?.toUInt64()
            self.ownerTradeFeeDenominator = keys["ownerTradeFeeDenominator"]?.toUInt64()
            self.ownerWithdrawFeeNumerator = keys["ownerWithdrawFeeNumerator"]?.toUInt64()
            self.ownerWithdrawFeeDenominator = keys["ownerWithdrawFeeDenominator"]?.toUInt64()
            self.hostFeeNumerator = keys["hostFeeNumerator"]?.toUInt64()
            self.hostFeeDenominator = keys["hostFeeDenominator"]?.toUInt64()
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
                (key: "hostFeeDenominator", length: 8),
                
            ]
        }
    }
}
