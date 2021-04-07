//
//  ParsedTransaction.swift
//  SolanaSwift
//
//  Created by Chung Tran on 05/04/2021.
//

import Foundation

public protocol SolanaSDKTransactionType {
    var signature: String {get}
}

public extension SolanaSDK {
    struct CreateAccountTransaction: SolanaSDKTransactionType {
        public let signature: String
        
        let fee: Double? // in SOL
        let newToken: Token?
        
        static var empty: Self {
            CreateAccountTransaction(signature: "", fee: nil, newToken: nil)
        }
    }
    
    struct CloseAccountTransaction: SolanaSDKTransactionType {
        public let signature: String
        
        let reimbursedAmount: Double?
        let closedToken: Token?
    }
    
    struct TransferTransaction: SolanaSDKTransactionType {
        public let signature: String
        
        let source: Token?
        let destination: Token?
        let amount: Double?
    }
    
    struct SwapTransaction: SolanaSDKTransactionType {
        public let signature: String
        
        // source
        let source: Token?
        let sourceAmount: Double?
        
        // destination
        let destination: Token?
        let destinationAmount: Double?
        
        static var empty: Self {
            SwapTransaction(signature: "", source: nil, sourceAmount: nil, destination: nil, destinationAmount: nil)
        }
    }
    
    struct EmptyTransaction: SolanaSDKTransactionType {
        private var id: String
        public let signature: String
        init(signature: String) {
            self.signature = signature
            if signature.isEmpty {
                id = UUID().uuidString
            } else {
                id = signature
            }
        }
    }
}
