//
//  Transaction.swift
//  SolanaSwift
//
//  Created by Chung Tran on 11/6/20.
//

import Foundation
import TweetNacl

public extension SolanaSDK {
    struct ConfirmedTransaction: Decodable {
        let message: Message
        let signatures: [String]
    }
}

public extension SolanaSDK.ConfirmedTransaction {
    struct Message: Decodable {
        let accountKeys: [SolanaSDK.Account.Meta]
        let instructions: [Instruction]
        let recentBlockhash: String
    }
    
    struct Instruction: Decodable {
        struct Parsed: Decodable {
            struct Info: Decodable {
                let owner: String
                let source: String?
                let account: String?
                
                // create account
                let lamports: UInt64?
                let newAccount: String?
                let space: UInt64?
                
                // initialize account
                let mint: String?
                let rentSysvar: String?
                
                // approve
                let amount: String?
                let delegate: String?
                
                // close
                let destination: String?
            }
            let info: Info
            let type: String // createAccount, initializeAccount, approve, closeAccount
        }
        
        let program: String?
        let programId: String
        let parsed: Parsed?
        
        // swap
        let data: String?
        let accounts: [String]?
    }
    
    struct Error: Decodable, Hashable {
        
    }
    
    struct Meta: Decodable {
        public let err: Error?
        public let fee: UInt64
        public let preBalances: [UInt64]
        public let postBalances: [UInt64]
    }
    
    struct Info: Decodable {
        public let meta: Meta?
        public let transaction: SolanaSDK.ConfirmedTransaction
        public let slot: UInt64?
    }
    
    struct SignatureInfo: Decodable, Hashable {
        public let signature: String
        public let slot: UInt64?
        public let err: Error?
        public let memo: String?
        
        public init(signature: String) {
            self.signature = signature
            self.slot = nil
            self.err = nil
            self.memo = nil
        }
    }
    
    struct Status: Decodable {
        public let err: Error?
        public let logs: [String]
    }
}
