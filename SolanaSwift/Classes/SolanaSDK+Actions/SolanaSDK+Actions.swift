//
//  SolanaSDK+Extensions.swift
//  SolanaSwift
//
//  Created by Chung Tran on 11/9/20.
//

import Foundation
import RxSwift

extension SolanaSDK {
    func serializeAndSend(
        transaction: Transaction,
        recentBlockhash: String? = nil,
        signers: [Account],
        isSimulation: Bool,
        accountsModifier: (([Account.Meta]) -> [Account.Meta])? = nil
    ) -> Single<String> {
        let maxAttemps = 3
        var numberOfTries = 0
        return serializeTransaction(
            transaction,
            recentBlockhash: recentBlockhash,
            signers: signers,
            accountsModifier: accountsModifier
        )
            .flatMap {
                if isSimulation {
                    return self.simulateTransaction(transaction: $0)
                        .map {result -> String in
                            if result.err != nil {
                                throw Error.other("Simulation error")
                            }
                            return "<simulated transaction id>"
                        }
                } else {
                    return self.sendTransaction(serializedTransaction: $0)
                }
            }
            .catchError {error in
                if numberOfTries <= maxAttemps,
                   let error = error as? SolanaSDK.Error
                {
                    var shouldRetry = false
                    switch error {
                    case .other(let message) where message == "Blockhash not found":
                        shouldRetry = true
                    case .invalidResponse(let response) where response.message == "Blockhash not found":
                        shouldRetry = true
                    default:
                        break
                    }
                    
                    if shouldRetry {
                        numberOfTries += 1
                        return self.serializeAndSend(transaction: transaction, signers: signers, isSimulation: isSimulation, accountsModifier: accountsModifier)
                    }
                }
                throw error
            }
    }
    
    func serializeTransaction(
        _ transaction: Transaction,
        recentBlockhash: String? = nil,
        signers: [Account],
        accountsModifier: (([Account.Meta]) -> [Account.Meta])? = nil
    ) -> Single<String> {
        // get recentBlockhash
        let getRecentBlockhashRequest: Single<String>
        if let recentBlockhash = recentBlockhash {
            getRecentBlockhashRequest = .just(recentBlockhash)
        } else {
            getRecentBlockhashRequest = getRecentBlockhash()
        }
        
        // serialize transaction
        return getRecentBlockhashRequest
            .map {recentBlockhash -> String in
                var transaction = transaction
                transaction.message.recentBlockhash = recentBlockhash
                try transaction.sign(signers: signers, accountsModifier: accountsModifier)
                guard let serializedTransaction = try transaction.serialize(accountsModifier: accountsModifier).toBase64() else {
                    throw Error.other("Could not serialize transaction")
                }
                return serializedTransaction
            }
    }
}
