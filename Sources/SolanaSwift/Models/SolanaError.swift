import Foundation

public enum SolanaError: Error, Equatable {
    public static func == (lhs: SolanaError, rhs: SolanaError) -> Bool {
        switch (lhs, rhs) {
        case let (.other(rs1), .other(rs2)):
            return rs1 == rs2
        case (.unknown, .unknown):
            return true
        default:
            return false
        }
    }

    // Other
    case other(String)
    case unknown

    // Predefined error
    public static var couldNotRetrieveAccountInfo: Self {
        .other("Could not retrieve account info")
    }
}
