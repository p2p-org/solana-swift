import Foundation

public enum VersionedTransactionError: Error, Equatable {
    case nonRequiredSigner(String)
    case unknownSigner(String)
    case noSigner
    case signatureVerificationError
    case unknown
}
