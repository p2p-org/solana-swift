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
    static let swapProgramId = try! SolanaSDK.PublicKey(string: "9qvG1zUp8xF1Bi4m6UdRNby1BAAuaDrUxSpv4CmRRMjL")
    static let poolAddress = try! SolanaSDK.PublicKey(string: "2FRBMKb1BffCjHTHRvTgX27wm7osZ194x1hoP8ykez99")
}
