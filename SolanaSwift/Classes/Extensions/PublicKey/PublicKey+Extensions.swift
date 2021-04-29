//
//  PublicKeys.swift
//  SolanaSwift
//
//  Created by Chung Tran on 20/01/2021.
//

import Foundation

public extension SolanaSDK.PublicKey {
    static let tokenProgramId = try! SolanaSDK.PublicKey(string: "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA")
    static let sysvarRent = try! SolanaSDK.PublicKey(string: "SysvarRent111111111111111111111111111111111")
    static let programId = try! SolanaSDK.PublicKey(string: "11111111111111111111111111111111")
    static let wrappedSOLMint = try! SolanaSDK.PublicKey(string: "So11111111111111111111111111111111111111112")
    static let ownerValidationProgramId = try! SolanaSDK.PublicKey(string: "4MNPdKu9wFMvEeZBMt3Eipfs5ovVWTJb31pEXDJAAxX5")
    static let swapHostFeeAddress = try! SolanaSDK.PublicKey(string: "AHLwq66Cg3CuDJTFtwjPfwjJhifiv6rFwApQNKgX57Yg")
    static let splAssociatedTokenAccountProgramId = try! SolanaSDK.PublicKey(string: "ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL")
}
