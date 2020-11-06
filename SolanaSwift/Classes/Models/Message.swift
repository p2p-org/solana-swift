//
//  Message.swift
//  SolanaSwift
//
//  Created by Chung Tran on 11/6/20.
//

import Foundation

extension SolanaSDK {
    struct Message {
        private static let RECENT_BLOCK_HASH_LENGT = 32
        
        private let header: Header
        private let recentBlockhash: String
        private let accountKeys: [AccountMeta]
//        private let 
    }
}

extension SolanaSDK.Message {
    typealias Byte = UInt8
    struct Header {
        static let LENGTH = 3
        // TODO:
        let numRequiredSignatures: Byte = 1
        let numReadonlySignedAccounts: Byte = 0
        let numReadonlyUnsignedAccounts: Byte = 1
        
        var bytes: [Byte] {
            [numRequiredSignatures, numReadonlySignedAccounts, numReadonlyUnsignedAccounts]
        }
    }
    
    struct CompiledInstruction {
        let programIdIndex: Byte
        let keyIndicesCount: [Byte]
        let keyIndices: [Byte]
        let dataLength: [Byte]
        let data: [Byte]
        
        var length: Int {
            1 + keyIndicesCount.count + keyIndices.count + dataLength.count + data.count
        }
    }
}
