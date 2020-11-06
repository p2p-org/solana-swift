//
//  TransactionInstruction.swift
//  SolanaSwift
//
//  Created by Chung Tran on 11/6/20.
//

import Foundation

public extension SolanaSDK {
    struct TransactionInstruction {
        public let keys: [AccountMeta]
        public let programId: PublicKey
        public let data: [Byte]
    }
}
