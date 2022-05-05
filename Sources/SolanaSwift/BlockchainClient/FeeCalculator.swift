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
        var depositFee: Lamports = 0
        for instruction in transaction.instructions {
            switch instruction.programId {
            case SystemProgram.id:
                guard instruction.data.count >= 2 else {break}
                let index = UInt32(bytes: instruction.data[0..<2])
                if index == SystemProgram.Index.create {
                    // Check if account is closed right after its creation
                    let initializingAccount = instruction.keys.first?.publicKey
                    let closingInstruction = transaction.instructions.first(
                        where: {
                            $0.data.first == TokenProgram.Index.closeAccount &&
                            $0.keys.first?.publicKey == initializingAccount
                        })
                    let isAccountClosedAfterCreation = closingInstruction != nil
                    
                    // If account is closed after creation, increase the deposit fee
                    if isAccountClosedAfterCreation {
                        depositFee += minRentExemption
                    }
                    
                    // Otherwise, there will be an account creation fee
                    else {
                        accountCreationFee += minRentExemption
                    }
                }
            case AssociatedTokenProgram.id:
                accountCreationFee += minRentExemption // data is empty
            default:
                break
            }
        }
        
        return .init(transaction: transactionFee, accountBalances: accountCreationFee, deposit: depositFee)
    }
}
