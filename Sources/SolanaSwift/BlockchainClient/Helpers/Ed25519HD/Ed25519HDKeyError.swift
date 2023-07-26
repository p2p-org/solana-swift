import Foundation

public enum Ed25519HDKeyError: Error {
    case invalidDerivationPath
    case hmacCanNotAuthenticate
    case canNotGetMasterKeyFromSeed
}
