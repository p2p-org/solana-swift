//
//  Decimals+Extensions.swift
//  SolanaSwift
//
//  Created by Chung Tran on 06/04/2021.
//

import Foundation

extension SolanaSDK.Decimals {
    static var SOL: SolanaSDK.Decimals { 9 }
}

extension SolanaSDK {
    public var solDecimals: SolanaSDK.Decimals {
        supportedTokens.first(where: {$0.symbol == "SOL"})?.decimals ?? 9
    }
}
