import Foundation

public enum SolanaError: Error, Equatable {
    case other(String)

    // Predefined error
    public static var couldNotRetrieveAccountInfo: Self {
        .other("Could not retrieve account info")
    }
}
