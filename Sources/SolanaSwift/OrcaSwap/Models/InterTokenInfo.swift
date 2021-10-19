//
//  InterTokenInfo.swift
//  
//
//  Created by Chung Tran on 14/10/2021.
//

import Foundation

extension OrcaSwap {
    public struct InterTokenInfo {
        public let tokenName: String
        public let outputAmount: UInt64?
        public let minAmountOut: UInt64?
        public let isStableSwap: Bool
    }
}
