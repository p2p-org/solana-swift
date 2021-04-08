//
//  ParsedTransaction.swift
//  SolanaSwift
//
//  Created by Chung Tran on 05/04/2021.
//

import Foundation

public extension SolanaSDK {
    struct AnyTransaction: Hashable {
        public init(signature: String, value: AnyHashable?) {
            self.signature = signature
            self.value = value
        }
        
        public let signature: String
        public let value: AnyHashable?
    }
    
    struct CreateAccountTransaction: Hashable {
        let fee: Double? // in SOL
        let newToken: Token?
        
        static var empty: Self {
            CreateAccountTransaction(fee: nil, newToken: nil)
        }
    }
    
    struct CloseAccountTransaction: Hashable {
        let reimbursedAmount: Double?
        let closedToken: Token?
    }
    
    struct TransferTransaction: Hashable {
        let source: Token?
        let destination: Token?
        let amount: Double?
    }
    
    struct SwapTransaction: Hashable {
        // source
        let source: Token?
        let sourceAmount: Double?
        
        // destination
        let destination: Token?
        let destinationAmount: Double?
        
        static var empty: Self {
            SwapTransaction(source: nil, sourceAmount: nil, destination: nil, destinationAmount: nil)
        }
    }
}
