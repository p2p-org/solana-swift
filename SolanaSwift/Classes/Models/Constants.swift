//
//  Constants.swift
//  SolanaSwift
//
//  Created by Chung Tran on 19/01/2021.
//

import Foundation

extension SolanaSDK {
    public struct Constants {
        public static let splTokenProgramId = try! PublicKey(string: "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA")
        public static let programId = try! PublicKey(string: "11111111111111111111111111111111")
        public static let sysvarRent = try! PublicKey(string: "SysvarRent111111111111111111111111111111111")
    }
}

