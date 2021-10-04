//
//  SerumSwap+Constants.swift
//  SolanaSwift
//
//  Created by Chung Tran on 17/08/2021.
//

import Foundation

extension SolanaSDK.PublicKey {
    static var usdcMint: SolanaSDK.PublicKey { try! SolanaSDK.PublicKey(string: "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v") }
    static var usdtMint: SolanaSDK.PublicKey { try! SolanaSDK.PublicKey(string: "Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB") }
    public static var dexPID: SolanaSDK.PublicKey { try! SolanaSDK.PublicKey(string: "9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin") }
    static var serumSwapPID: SolanaSDK.PublicKey { try! SolanaSDK.PublicKey(string: "22Y43yTVxuUkoRKdm9thyRhQ3SdgQS7c7kB6UNCiaczD") }
    var isUsdx: Bool {
        self == .usdcMint || self == .usdtMint
    }
}

extension UInt64 {
    var digitsSum: Int {
        var n = 1
        var i = self
        if i >= 100000000 { n += 8; i /= 100000000 }
        if i >= 10000     { n += 4; i /= 10000 }
        if i >= 100       { n += 2; i /= 100 }
        if i >= 10        { n += 1; }
        return n
    }
}

extension Decimal {
    var doubleValue: Double {
        return NSDecimalNumber(decimal:self).doubleValue
    }
}
