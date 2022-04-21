//
//  SolanaSDK+Extensions.swift
//  SolanaSwift
//
//  Created by Chung Tran on 11/9/20.
//

import Foundation
import RxSwift

extension SolanaSDK {
    public func prepareTransaction(
        instructions: [TransactionInstruction],
        signers: [Account],
        feePayer: PublicKey,
        accountsCreationFee: Lamports,
        recentBlockhash: String? = nil,
        lamportsPerSignature: Lamports? = nil
    ) -> Single<PreparedTransaction> {
        // get recentBlockhash
        let getRecentBlockhashRequest: Single<String>
        if let recentBlockhash = recentBlockhash {
            getRecentBlockhashRequest = .just(recentBlockhash)
        } else {
            getRecentBlockhashRequest = getRecentBlockhash()
        }
        
        // get lamports per signature
        let getLamportsPerSignature: Single<Lamports>
        if let lamportsPerSignature = lamportsPerSignature {
            getLamportsPerSignature = .just(lamportsPerSignature)
        } else {
            getLamportsPerSignature = getFees().map {$0.feeCalculator?.lamportsPerSignature}.map {$0 ?? 0}
        }
        
        return Single.zip(
            getLamportsPerSignature,
            getRecentBlockhashRequest
        )
            .map { lamportsPerSignature, recentBlockhash in
                var transaction = Transaction()
                transaction.instructions = instructions
                transaction.recentBlockhash = recentBlockhash
                transaction.feePayer = feePayer
                
                // calculate fee first
                let expectedFee = FeeAmount(
                    transaction: try transaction.calculateTransactionFee(lamportsPerSignatures: lamportsPerSignature),
                    accountBalances: accountsCreationFee
                )
                
                // resign transaction
                try transaction.sign(signers: signers)
                
                return .init(transaction: transaction, signers: signers, expectedFee: expectedFee)
            }
    }
    
    public func serializeAndSend(
        preparedTransaction: PreparedTransaction,
        isSimulation: Bool
    ) -> Single<String> {
        do {
            let serializedTransaction = try preparedTransaction.serialize()
            let request: Single<String>
            
            if isSimulation {
                request = simulateTransaction(transaction: serializedTransaction)
                    .map {result -> String in
                        if result.err != nil {
                            throw Error.other("Simulation error")
                        }
                        return "<simulated transaction id>"
                    }
            } else {
                request = sendTransaction(serializedTransaction: serializedTransaction)
            }
            
            let maxAttemps = 3
            var numberOfTries = 0
            return request
                .catch {[weak self] error in
                    guard let self = self else {throw Error.unknown}
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
                            return self.serializeAndSend(preparedTransaction: preparedTransaction, isSimulation: isSimulation)
                        }
                    }
                    throw error
                }
        } catch {
            return .error(error)
        }
    }
    
    /// Traditional sending without FeeRelayer
    /// - Parameters:
    ///   - instructions: transaction's instructions
    ///   - recentBlockhash: recentBlockhash
    ///   - signers: signers
    ///   - isSimulation: define if this is a simulation or real transaction
    /// - Returns: transaction id
    public func serializeAndSend(
        instructions: [TransactionInstruction],
        recentBlockhash: String? = nil,
        signers: [Account],
        isSimulation: Bool
    ) -> Single<String> {
        let maxAttemps = 3
        var numberOfTries = 0
        return serializeTransaction(
            instructions: instructions,
            recentBlockhash: recentBlockhash,
            signers: signers
        )
            .flatMap { [weak self] transaction in
                guard let self = self else {throw Error.unknown}
                if isSimulation {
                    return self.simulateTransaction(transaction: transaction)
                        .map {result -> String in
                            if result.err != nil {
                                throw Error.other("Simulation error")
                            }
                            return "<simulated transaction id>"
                        }
                } else {
                    return self.sendTransaction(serializedTransaction: transaction)
                }
            }
            .catch { [weak self] error in
                guard let self = self else {throw Error.unknown}
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
                        return self.serializeAndSend(instructions: instructions, signers: signers, isSimulation: isSimulation)
                    }
                }
                throw error
            }
    }
    
    public func serializeTransaction(
        instructions: [TransactionInstruction],
        recentBlockhash: String? = nil,
        signers: [Account],
        feePayer: PublicKey? = nil
    ) -> Single<String> {
        // get recentBlockhash
        let getRecentBlockhashRequest: Single<String>
        if let recentBlockhash = recentBlockhash {
            getRecentBlockhashRequest = .just(recentBlockhash)
        } else {
            getRecentBlockhashRequest = getRecentBlockhash()
        }
        
        guard let feePayer = feePayer ?? accountStorage.account?.publicKey else {
            return .error(Error.invalidRequest(reason: "Fee-payer not found"))
        }
        
        // serialize transaction
        return getRecentBlockhashRequest
            .map {recentBlockhash -> String in
                var transaction = Transaction()
                transaction.instructions = instructions
                transaction.feePayer = feePayer
                transaction.recentBlockhash = recentBlockhash
                try transaction.sign(signers: signers)
                let serializedTransaction = try transaction.serialize().bytes.toBase64()
                
                if let decodedTransaction = transaction.jsonString {
                    Logger.log(message: decodedTransaction, event: .info)
                    Logger.log(message: serializedTransaction, event: .info)
                }
                
                return serializedTransaction
            }
    }
}
