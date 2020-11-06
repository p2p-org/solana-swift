//
//  AccountMeta.swift
//  SolanaSwift
//
//  Created by Chung Tran on 11/6/20.
//

import Foundation

public extension SolanaSDK {
    struct AccountMeta {
        public let publicKey: PublicKey
        public let isSigner: Bool
        public let isWritable: Bool
    }
}
