import Foundation

public enum SolanaError: Error, Equatable {
    public static func == (lhs: SolanaError, rhs: SolanaError) -> Bool {
        switch (lhs, rhs) {
        case (.notFound, .notFound):
            return true
        case let (.invalidRequest(rs1), .invalidRequest(rs2)):
            return rs1 == rs2
        case let (.other(rs1), .other(rs2)):
            return rs1 == rs2
        case (.unknown, .unknown):
            return true
        case let (.transactionError(err1, logs1), .transactionError(err2, logs2)):
            return err1.jsonString == err2.jsonString && logs1 == logs2
        default:
            return false
        }
    }

    case notFound
    case assertionFailed(String? = nil)

    // Invalid Requests
    case invalidRequest(reason: String? = nil)

    // Transaction error
    case transactionError(ErrorDetail, logs: [String])

    // Other
    case other(String)
    case unknown

    // Predefined error
    public static var couldNotRetrieveAccountInfo: Self {
        .other("Could not retrieve account info")
    }
}
