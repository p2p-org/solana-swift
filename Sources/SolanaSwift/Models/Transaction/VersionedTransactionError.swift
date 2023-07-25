import Foundation

public enum VersionedTransactionError: Error, Equatable {
    case nonRequiredSigner(String)
    case unknownSigner(String)
    case invalidSigner(String)
    case noSigner
    case signatureVerificationError
    case signatureNotFound
    case noInstructionProvided
    case feePayerNotFound
    case recentBlockhashNotFound
    case unknown
}
