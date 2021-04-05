//
//  Others.swift
//  SolanaSwift
//
//  Created by Chung Tran on 05/04/2021.
//

import Foundation

public extension SolanaSDK {
    struct TransactionError: Decodable, Hashable {
        
    }
    
    struct TransactionMeta: Decodable {
        public let err: TransactionError?
        public let fee: UInt64
        public let preBalances: [UInt64]
        public let postBalances: [UInt64]
    }
    
    struct TransactionInfo: Decodable {
        public let meta: TransactionMeta?
        public let transaction: SolanaSDK.ConfirmedTransaction
        public let slot: UInt64?
    }
    
    struct SignatureInfo: Decodable, Hashable {
        public let signature: String
        public let slot: UInt64?
        public let err: TransactionError?
        public let memo: String?
        
        public init(signature: String) {
            self.signature = signature
            self.slot = nil
            self.err = nil
            self.memo = nil
        }
    }
    
    struct TransactionStatus: Decodable {
        public let err: TransactionError?
        public let logs: [String]
    }
}
