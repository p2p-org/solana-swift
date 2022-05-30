import Foundation

public enum TransactionStatus: Equatable, Hashable {
    case sending
    case confirmed(numberOfConfirmations: UInt64)
    case finalized
    case error(String?)

    var numberOfConfirmations: UInt64 {
        switch self {
        case let .confirmed(numberOfConfirmations):
            return numberOfConfirmations
        default:
            return 0
        }
    }
}
