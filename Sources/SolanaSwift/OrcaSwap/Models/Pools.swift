//
//  File.swift
//  
//
//  Created by Chung Tran on 13/10/2021.
//

import Foundation

extension OrcaSwap {
    struct Pool: Decodable {
        let account: String
        let authority: String
        let nonce: UInt64
        let poolTokenMint: String
        let tokenAccountA: String
        let tokenAccountB: String
        let feeAccount: String
        let hostFeeAccount: String?
        let feeNumerator: UInt64
        let feeDenominator: UInt64
        let ownerTradeFeeNumerator: UInt64
        let ownerTradeFeeDenominator: UInt64
        let ownerWithdrawFeeNumerator: UInt64
        let ownerWithdrawFeeDenominator: UInt64
        let hostFeeNumerator: UInt64
        let hostFeeDenominator: UInt64
        let tokenAName: String
        let tokenBName: String
        let curveType: String
        let amp: UInt64?
        let programVersion: UInt64?
        let deprecated: Bool?
    }
    
    typealias Pools = [String: Pool] // [poolId: string]: PoolConfig;
}
