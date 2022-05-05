//
//  File.swift
//  
//
//  Created by Chung Tran on 05/05/2022.
//

import Foundation

public protocol FeeCalculator: AnyObject {
    func calculateNetworkFee(transaction: Transaction) throws -> FeeAmount
}

public class DefaultFeeCalculator: FeeCalculator {
    private let lamportsPerSignature: Lamports
    private let minRentExemption: Lamports
    
    public init(lamportsPerSignature: Lamports, minRentExemption: Lamports) {
        self.lamportsPerSignature = lamportsPerSignature
        self.minRentExemption = minRentExemption
    }
    
    public func calculateNetworkFee(transaction: Transaction) throws -> FeeAmount {
        var transaction = transaction
        let transactionFee = try transaction.calculateTransactionFee(lamportsPerSignatures: lamportsPerSignature)
        var accountCreationFee: Lamports = 0
//        var depositFee: Lamports = 0
        for instruction in transaction.instructions {
            switch instruction.programId {
            case AssociatedTokenProgram.id:
                accountCreationFee += minRentExemption // data is empty
            case TokenProgram.id:
                guard instruction.data.count >= 1 else {break}
                let index = instruction.data.first!
                switch index {
                case TokenProgram.Index.initializeAccount:
                    accountCreationFee += minRentExemption
                    
                // TODO: - Deposit fee
//                case TokenProgram.Index.closeAccount:
//                    if accountCreationFee > minRentExemption {
//                        accountCreationFee -= minRentExemption
//                    } else {
//                        depositFee += minRentExemption
//                    }
                default:
                    break
                }
                
            default:
                break
            }
        }
        
        return .init(transaction: transactionFee, accountBalances: accountCreationFee)
    }
}
