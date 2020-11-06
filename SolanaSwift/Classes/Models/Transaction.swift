//
//  Transaction.swift
//  SolanaSwift
//
//  Created by Chung Tran on 11/6/20.
//

import Foundation

public extension SolanaSDK {
    struct Transaction: Decodable {
        public let signatures: [Byte]
        public let message: Message
        
        enum CodingKeys: String, CodingKey {
            case message, signatures
        }
        public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            message = try values.decode(Message.self, forKey: .message)
            let strings = try values.decode([String].self, forKey: .signatures)
            signatures = strings.compactMap {Byte($0)}
        }
    }
}

public extension SolanaSDK.Transaction {
    struct Instruction: Decodable {
        public let keys: [SolanaSDK.Account.Meta]
        public let programId: SolanaSDK.PublicKey
        public let data: [SolanaSDK.Byte]
    }
    
    struct Error: Decodable {
        
    }
    
    struct Meta: Decodable {
        public let err: Error?
        public let fee: UInt64
        public let preBalances: [UInt64]
        public let postBalances: [UInt64]
    }
    
    struct Info: Decodable {
        public let meta: Meta?
        public let transaction: SolanaSDK.Transaction
        public let slot: UInt64?
    }
    
    struct SignatureInfo: Decodable {
        public let signature: String
        public let slot: UInt64
        public let err: Error?
        public let memo: String?
    }
    
    struct Status: Decodable {
        public let err: Error?
        public let logs: [String]
    }
}
