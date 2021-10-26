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
        public let message: Message
        let signatures: [String]
    }
}

public extension SolanaSDK.ConfirmedTransaction {
    struct Message: Decodable {
        public let accountKeys: [SolanaSDK.Account.Meta]
        public let instructions: [SolanaSDK.ParsedInstruction]
        public let recentBlockhash: String
    }
}

public extension SolanaSDK {
    struct ParsedInstruction: Decodable {
        struct Parsed: Decodable {
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
                let wallet: String? // spl-associated-token-account
                
                // transferChecked
                let tokenAmount: TokenAccountBalance?
            }
            
            let info: Info
            let type: String?
        }
        
        let program: String?
        let programId: String
        let parsed: Parsed?
        
        // swap
        public let data: String?
        let accounts: [String]?
    }
}

extension Sequence where Iterator.Element == SolanaSDK.ParsedInstruction {
    func containProgram(with name: String) -> Bool {
        getFirstProgram(with: name) != nil
    }
    
    func getFirstProgram(with name: String) -> SolanaSDK.ParsedInstruction? {
        first(where: { $0.program == name })
    }
}
