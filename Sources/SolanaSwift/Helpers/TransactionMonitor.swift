import Foundation
import Task_retrying

class TransactionMonitor<SolanaAPIClient: SolanaSwift.SolanaAPIClient> {
    let signature: String
    let apiClient: SolanaAPIClient
    let timeout: Int
    let delay: Int
    var responseHandler: (PendingTransactionStatus) -> Void
    var timedOutHandler: () -> Void
    var task: Task<Void, Error>!
    var currentStatus: PendingTransactionStatus!

    init(
        apiClient: SolanaAPIClient,
        signature: String,
        timeout: Int,
        delay: Int,
        responseHandler: @escaping (PendingTransactionStatus) -> Void,
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
                if let error = error as? TaskRetryingError,
                   error.type == .timedOut
                {
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
            throw TransactionConfirmationError.unconfirmed
        }
    }

    func stopMonitoring() {
        task.cancel()
    }

    func setStatus(_ transactionStatus: PendingTransactionStatus) {
        currentStatus = transactionStatus
        responseHandler(transactionStatus)
    }
}
