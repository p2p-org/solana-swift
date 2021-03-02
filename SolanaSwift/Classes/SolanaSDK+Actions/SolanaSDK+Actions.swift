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
        isSimulation: Bool
    ) -> Single<String> {
        let maxAttemps = 3
        var numberOfTries = 0
        return serializeTransaction(
            transaction,
            recentBlockhash: recentBlockhash,
            signers: signers
        )
            .flatMap {
                if isSimulation {
                    return self.simulateTransaction(transaction: $0)
                        .map {result -> String in
                            if result.err != nil {
                                throw Error.other("Simulation error")
                            }
                            return ""
                        }
                } else {
                    return self.sendTransaction(serializedTransaction: $0)
                }
            }
            .catch {error in
                if (error as? Error) == Error.other("Blockhash not found"),
                   numberOfTries <= maxAttemps
                {
                    numberOfTries += 1
                    return self.serializeAndSend(transaction: transaction, signers: signers, isSimulation: isSimulation)
                }
                throw error
            }
    }
    
    func serializeTransaction(
        _ transaction: Transaction,
        recentBlockhash: String? = nil,
        signers: [Account]
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
                try transaction.sign(signers: signers)
                guard let serializedTransaction = try transaction.serialize().toBase64() else {
                    throw Error.other("Could not serialize transaction")
                }
                return serializedTransaction
            }
    }
}
