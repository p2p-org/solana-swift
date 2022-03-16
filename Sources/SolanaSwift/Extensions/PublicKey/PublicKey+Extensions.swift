//
//  PublicKeys.swift
//  SolanaSwift
//
//  Created by Chung Tran on 20/01/2021.
//

import Foundation

public extension SolanaSDK.PublicKey {
    static var tokenProgramId: SolanaSDK.PublicKey { "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA" }
    static var sysvarRent: SolanaSDK.PublicKey { "SysvarRent111111111111111111111111111111111" }
    static var programId: SolanaSDK.PublicKey { "11111111111111111111111111111111" }
    static var wrappedSOLMint: SolanaSDK.PublicKey { "So11111111111111111111111111111111111111112" }
    static var solMint: SolanaSDK.PublicKey { "Ejmc1UB4EsES5oAaRN63SpoxMJidt3ZGBrqrZk49vjTZ" } // Arbitrary mint to represent SOL (not wrapped SOL).
    static var ownerValidationProgramId: SolanaSDK.PublicKey { "4MNPdKu9wFMvEeZBMt3Eipfs5ovVWTJb31pEXDJAAxX5" }
    static var swapHostFeeAddress: SolanaSDK.PublicKey { "AHLwq66Cg3CuDJTFtwjPfwjJhifiv6rFwApQNKgX57Yg" }
    static var splAssociatedTokenAccountProgramId: SolanaSDK.PublicKey { "ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL" }
    static var renBTCMint: SolanaSDK.PublicKey { "CDJWUqTcYTVAKXAVXoQZFes5JUFc7owSeq7eMQcDSbo5" }
    static var renBTCMintDevnet: SolanaSDK.PublicKey { "FsaLodPu4VmSwXGr3gWfwANe4vKf8XSZcCh1CEeJ3jpD" }
    static var fake: SolanaSDK.PublicKey { "BGcmLttQoYIw4Yfzc7RkZJCKR53IlAybgq8HK0vmovP0\n" }
    
    static func orcaSwapId(version: Int = 2) -> SolanaSDK.PublicKey {
        switch version {
        case 2:
            return "9W959DqEETiGZocYWCQPaJ6sBmUzgfxXfqGeTEdp3aQP"
        default:
            return "DjVE6JNiYqPL2QXyCUUh8rNjHrbz9hXHNYt99MQ59qw1"
        }
    }

    static var usdcMint: SolanaSDK.PublicKey { "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v"}
    static var usdtMint: SolanaSDK.PublicKey { "Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB" }
    static var dexPID: SolanaSDK.PublicKey { "9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin" }
    static var serumSwapPID: SolanaSDK.PublicKey { "22Y43yTVxuUkoRKdm9thyRhQ3SdgQS7c7kB6UNCiaczD" }
    var isUsdx: Bool {
        self == .usdcMint || self == .usdtMint
    }
}
