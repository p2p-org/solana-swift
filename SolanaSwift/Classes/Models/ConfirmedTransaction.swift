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
        let instructions: [SolanaSDK.ParsedInstruction]
        public let recentBlockhash: String
    }
}

extension SolanaSDK {
    struct ParsedInstruction: Decodable {
        struct Parsed: Decodable {
            enum InstructionType: String, Decodable {
                case createAccount, initializeAccount, approve, closeAccount, swap, transfer
            }
            
            struct Info: Decodable {
                let owner: String?
                let account: String?
                let source: String?
                let destination: String?
                
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
                
                // transfer
                let authority: String?
            }
            let info: Info
            let type: InstructionType
        }
        
        let program: String?
        let programId: String
        let parsed: Parsed?
        
        // swap
        let data: String?
        let accounts: [String]?
    }
}
