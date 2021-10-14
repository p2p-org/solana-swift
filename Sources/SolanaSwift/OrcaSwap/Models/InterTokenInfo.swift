//
//  InterTokenInfo.swift
//  
//
//  Created by Chung Tran on 14/10/2021.
//

import Foundation

extension OrcaSwap {
    public struct InterTokenInfo {
        let tokenName: String
        let outputAmount: UInt64?
        let minAmountOut: UInt64?
        let isStableSwap: Bool
    }
}
