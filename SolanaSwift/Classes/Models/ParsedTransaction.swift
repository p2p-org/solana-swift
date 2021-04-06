//
//  ParsedTransaction.swift
//  SolanaSwift
//
//  Created by Chung Tran on 05/04/2021.
//

import Foundation

protocol SolanaSDKTransactionType {
    
}

public extension SolanaSDK {
    struct CreateAccountTransaction: SolanaSDKTransactionType {
        let fee: Double? // in SOL
        let mint: PublicKey?
        let newAccount: PublicKey?
        
        static var empty: Self {
            CreateAccountTransaction(fee: nil, mint: nil, newAccount: nil)
        }
    }
    
    struct CloseAccountTransaction: SolanaSDKTransactionType {
        let reimbursedAmount: Double?
        let mint: PublicKey?
    }
    
    struct SwapTransaction: SolanaSDKTransactionType {
        // source
        let source: PublicKey?
        let sourceInfo: AccountInfo?
        let sourceAmount: Double?
        
        // destination
        let destination: PublicKey?
        let destinationInfo: AccountInfo?
        let destinationAmount: Double?
        
        static var empty: Self {
            SwapTransaction(source: nil, sourceInfo: nil, sourceAmount: nil, destination: nil, destinationInfo: nil, destinationAmount: nil)
        }
    }
}
