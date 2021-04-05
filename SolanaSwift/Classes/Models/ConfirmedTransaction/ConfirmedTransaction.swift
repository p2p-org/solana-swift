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
        public let accountKeys: [SolanaSDK.Account.Meta]
        let instructions: [Instruction]
        public let recentBlockhash: String
        
//        public var parsedInstructions: [SolanaSDKInstructionType] {
//
//        }
    }
}

extension SolanaSDK.ConfirmedTransaction.Message {
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
}
