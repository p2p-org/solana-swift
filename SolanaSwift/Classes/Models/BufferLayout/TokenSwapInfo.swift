//
//  TokenSwapInfo.swift
//  SolanaSwift
//
//  Created by Chung Tran on 21/01/2021.
//

import Foundation

extension SolanaSDK {
    public struct TokenSwapInfo: DecodableBufferLayout, Equatable, Hashable, Encodable {
        public let version: UInt8
        public let isInitialized: Bool
        public let nonce: UInt8
        public let tokenProgramId: PublicKey
        public var tokenAccountA: PublicKey
        public var tokenAccountB: PublicKey
        public let tokenPool: PublicKey
        public var mintA: PublicKey
        public var mintB: PublicKey
        public let feeAccount: PublicKey
        public let tradeFeeNumerator: UInt64
        public let tradeFeeDenominator: UInt64
        public let ownerTradeFeeNumerator: UInt64
        public let ownerTradeFeeDenominator: UInt64
        public let ownerWithdrawFeeNumerator: UInt64
        public let ownerWithdrawFeeDenominator: UInt64
        public let hostFeeNumerator: UInt64
        public let hostFeeDenominator: UInt64
        public let curveType: UInt8
        public let payer: PublicKey
        
        public static var BUFFER_LENGTH: Int { 324 }
        
        public static var span: UInt64 {
            UInt64(BUFFER_LENGTH)
        }
    }
}
