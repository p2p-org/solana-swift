//
//  ParsedTransaction.swift
//  SolanaSwift
//
//  Created by Chung Tran on 05/04/2021.
//

import Foundation

extension SolanaSDK {
    struct ParsedTransaction {
        // MARK: - Properties
        
        // MARK: - Initializers
        init(transactionInfo: TransactionInfo) {
            let innerInstructions = transactionInfo.meta?.innerInstructions
            let instructions = transactionInfo.transaction.message.instructions
            let preBalances = transactionInfo.meta?.preBalances
            let preTokenBalances = transactionInfo.meta?.preTokenBalances
            
            
        }
    }
}
