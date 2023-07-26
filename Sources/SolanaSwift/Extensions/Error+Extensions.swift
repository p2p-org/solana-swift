import Foundation
import Task_retrying

extension Error {
    func isEqualTo(_ error: TransactionConfirmationError) -> Bool {
        (self as? TransactionConfirmationError) == error
    }

    func isEqualTo(_ error: APIClientError) -> Bool {
        (self as? APIClientError) == error
    }
}
