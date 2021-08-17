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
    static var dexPID: SolanaSDK.PublicKey { try! SolanaSDK.PublicKey(string: "9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin") }
    static var serumSwapPID: SolanaSDK.PublicKey { try! SolanaSDK.PublicKey(string: "22Y43yTVxuUkoRKdm9thyRhQ3SdgQS7c7kB6UNCiaczD") }
    var isUsdx: Bool {
        self == .usdcMint || self == .usdtMint
    }
}
