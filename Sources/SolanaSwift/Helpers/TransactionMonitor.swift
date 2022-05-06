//
//  File.swift
//  
//
//  Created by Chung Tran on 06/05/2022.
//

import Foundation

class TransactionMonitor<SolanaAPIClient: SolanaSwift.SolanaAPIClient> {
    let signature: String
    let apiClient: SolanaAPIClient
    var responseHandler: (TransactionStatus) -> Void
    var timedOutHandler: () -> Void
    var task: Task<Void, Error>!
    var currentStatus: TransactionStatus!
    
    init(apiClient: SolanaAPIClient, signature: String, responseHandler: @escaping (TransactionStatus) -> Void, timedOutHandler: @escaping () -> Void) {
        self.apiClient = apiClient
        self.signature = signature
        self.responseHandler = responseHandler
        self.timedOutHandler = timedOutHandler
    }
    
    func startMonitoring() {
        setStatus(.sending)
        
        task = Task.retrying(
            where: { [weak self] error in
                guard let self = self else {return false}
                if let error = error as? CustomTaskError, error == .timedOut {
                    self.timedOutHandler()
                    return false
                }
                return true
            },
            maxRetryCount: .max,
            retryDelay: 1,
            timeoutInSeconds: 3
        ) { [weak self] in
            guard let self = self else {return}
            try Task.checkCancellation()
            let status = try await self.apiClient.getSignatureStatus(signature: self.signature)
            
            if let confirmations = status.confirmations, status.confirmationStatus == "confirmed" {
                self.setStatus(.confirmed(numberOfConfirmations: confirmations))
            }
            let finalized = status.confirmations == nil || status.confirmationStatus == "finalized"
            if finalized {
                self.setStatus(.finalized)
                return
            }
            throw SolanaError.other("Transaction has not been confirmed")
        }
    }
    
    func stopMonitoring() {
        task.cancel()
    }
    
    func setStatus(_ transactionStatus: TransactionStatus) {
        currentStatus = transactionStatus
        responseHandler(transactionStatus)
    }
}
