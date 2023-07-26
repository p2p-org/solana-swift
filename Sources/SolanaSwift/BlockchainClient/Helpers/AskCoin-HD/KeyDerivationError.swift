import Foundation

public enum KeyDerivationError: Error {
    case indexInvalid
    case pathInvalid
    case privateKeyNil
    case publicKeyNil
    case chainCodeNil
    case notMasterKey
}
