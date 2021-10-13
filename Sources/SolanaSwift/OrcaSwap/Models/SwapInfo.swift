//
//  File.swift
//  
//
//  Created by Chung Tran on 13/10/2021.
//

import Foundation

extension OrcaSwap {
    public struct SwapInfo {
        let routes: Routes
        let tokens: Tokens
        let pools: Pools
        let programIds: ProgramID
        let tokenNames: [String: String] // [Mint: TokenName]
    }
}
