import Foundation

public enum SolanaError: Swift.Error, Equatable {
    public static func == (lhs: SolanaError, rhs: SolanaError) -> Bool {
        switch (lhs, rhs) {
        case (.unauthorized, .unauthorized):
            return true
        case (.notFound, .notFound):
            return true
        case let (.invalidRequest(rs1), .invalidRequest(rs2)):
            return rs1 == rs2
        case let (.invalidResponse(rs1), .invalidResponse(rs2)):
            return rs1.code == rs2.code
        case let (.socket(er1), .socket(er2)):
            return er1.localizedDescription == er2.localizedDescription
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

    case unauthorized
    case notFound
    case assertionFailed(String? = nil)

    // Invalid Requests
    case invalidRequest(reason: String? = nil)

    // Invalid responses
    case invalidResponse(ResponseError)

    // Transaction error
    case transactionError(ErrorDetail, logs: [String])

    // Socket error
    case socket(Swift.Error)

    // Transaction has not been confirmed
    case transactionHasNotBeenConfirmed

    // Other
    case other(String)
    case unknown

    // Predefined error
    public static var couldNotRetrieveAccountInfo: Self {
        .other("Could not retrieve account info")
    }

    public static var couldNotRetrieveBuffer: Self {
        .other("Could not retrieve buffer")
    }
}
