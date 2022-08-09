//
//  File.swift
//
//
//  Created by Chung Tran on 06/05/2022.
//

import Foundation
import Task_retrying

class TransactionMonitor<SolanaAPIClient: SolanaSwift.SolanaAPIClient> {
    let signature: String
    let apiClient: SolanaAPIClient
    let timeout: Int
    let delay: Int
    var responseHandler: (TransactionStatus) -> Void
    var timedOutHandler: () -> Void
    var task: Task<Void, Error>!
    var currentStatus: TransactionStatus!

    init(
        apiClient: SolanaAPIClient,
        signature: String,
        timeout: Int,
        delay: Int,
        responseHandler: @escaping (TransactionStatus) -> Void,
        timedOutHandler: @escaping () -> Void
    ) {
        self.apiClient = apiClient
        self.signature = signature
        self.timeout = timeout
        self.delay = delay
        self.responseHandler = responseHandler
        self.timedOutHandler = timedOutHandler
    }

    func startMonitoring() {
        setStatus(.sending)

        task = Task.retrying(
            where: { [weak self] error in
                guard let self = self else { return false }
                if let error = error as? TaskRetryingError, error == .timedOut {
                    self.timedOutHandler()
                    return false
                }
                return true
            },
            maxRetryCount: .max,
            retryDelay: TimeInterval(delay),
            timeoutInSeconds: timeout
        ) { [weak self] in
            guard let self = self else { return }
            try Task.checkCancellation()
            let status = try await self.apiClient.getSignatureStatus(signature: self.signature, configs: nil)

            if let confirmations = status.confirmations, status.confirmationStatus == "confirmed" {
                self.setStatus(.confirmed(numberOfConfirmations: confirmations, slot: status.slot))
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
