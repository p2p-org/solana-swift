//
//  PublicKeys.swift
//  SolanaSwift
//
//  Created by Chung Tran on 20/01/2021.
//

import Foundation

public extension SolanaSDK.PublicKey {
    static let tokenProgramId: SolanaSDK.PublicKey = "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA"
    static let sysvarRent: SolanaSDK.PublicKey = "SysvarRent111111111111111111111111111111111"
    static let programId: SolanaSDK.PublicKey = "11111111111111111111111111111111"
    static let wrappedSOLMint: SolanaSDK.PublicKey = "So11111111111111111111111111111111111111112"
    static let solMint: SolanaSDK.PublicKey = "Ejmc1UB4EsES5oAaRN63SpoxMJidt3ZGBrqrZk49vjTZ" // Arbitrary mint to represent SOL (not wrapped SOL).
    static let ownerValidationProgramId: SolanaSDK.PublicKey = "4MNPdKu9wFMvEeZBMt3Eipfs5ovVWTJb31pEXDJAAxX5"
    static let swapHostFeeAddress: SolanaSDK.PublicKey = "AHLwq66Cg3CuDJTFtwjPfwjJhifiv6rFwApQNKgX57Yg"
    static let splAssociatedTokenAccountProgramId: SolanaSDK.PublicKey = "ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL"
    static let renBTCMint: SolanaSDK.PublicKey = "CDJWUqTcYTVAKXAVXoQZFes5JUFc7owSeq7eMQcDSbo5"
    static let renBTCMintDevnet: SolanaSDK.PublicKey = "FsaLodPu4VmSwXGr3gWfwANe4vKf8XSZcCh1CEeJ3jpD"
    static let fake: SolanaSDK.PublicKey = "BGcmLttQoYIw4Yfzc7RkZJCKR53IlAybgq8HK0vmovP0\n"
    
    static func orcaSwapId(version: Int = 2) -> SolanaSDK.PublicKey {
        switch version {
        case 2:
            return "9W959DqEETiGZocYWCQPaJ6sBmUzgfxXfqGeTEdp3aQP"
        default:
            return "DjVE6JNiYqPL2QXyCUUh8rNjHrbz9hXHNYt99MQ59qw1"
        }
    }
}
