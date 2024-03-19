import CommonCrypto
import Foundation
import TweetNacl

@available(*, deprecated, renamed: "KeyPair")
public typealias Account = KeyPair

public extension KeyPair {
    @available(*, deprecated, renamed: "AccountMeta")
    typealias Meta = AccountMeta
}

public enum KeyPairError: Error, Equatable {
    case couldNotDerivatePrivateKey
}

public struct KeyPair: Codable, Hashable {
    public let phrase: [String]
    public let publicKey: PublicKey
    public let secretKey: Data

    public init() throws {
        let keys = try NaclSign.KeyPair.keyPair()
        publicKey = try PublicKey(data: keys.publicKey)
        secretKey = keys.secretKey
        let phrase = try Mnemonic.toMnemonic(secretKey.bytes)
        self.phrase = phrase
    }

    public init(phrase: [String], publicKey: PublicKey, secretKey: Data) {
        self.phrase = phrase
        self.publicKey = publicKey
        self.secretKey = secretKey
    }

    public init(secretKey: Data) throws {
        let keys = try NaclSign.KeyPair.keyPair(fromSecretKey: secretKey)
        publicKey = try PublicKey(data: keys.publicKey)
        self.secretKey = keys.secretKey
        let phrase = try Mnemonic.toMnemonic(secretKey.bytes)
        self.phrase = phrase
    }

    public init(
        seed: String,
        salt: String,
        passphrase _: String,
        network: Network,
        derivablePath: DerivablePath
    ) async throws {
        self = try await Task {
            let publicKey: PublicKey
            let secretKey: Data

            switch derivablePath.type {
            case .deprecated:
                let keychain = try Keychain(seed: seed, salt: salt, network: network.cluster)
                guard let seed = try keychain?.derivedKeychain(at: derivablePath.rawValue).privateKey else {
                    throw KeyPairError.couldNotDerivatePrivateKey
                }

                let keys = try NaclSign.KeyPair.keyPair(fromSeed: seed)

                publicKey = try .init(data: keys.publicKey)
                secretKey = keys.secretKey
            default:
                let password = (seed as NSString).decomposedStringWithCompatibilityMapping
                let salt = (salt as NSString).decomposedStringWithCompatibilityMapping
                guard let seedBytes = pbkdf2(
                    hash: CCPBKDFAlgorithm(kCCPRFHmacAlgSHA512),
                    password: password,
                    salt: Data(salt.bytes),
                    keyByteCount: 64,
                    rounds: 2048
                )?.bytes else {
                    throw KeyPairError.couldNotDerivatePrivateKey
                }

                let keys = try Ed25519HDKey.derivePath(derivablePath.rawValue, seed: seedBytes.toHexString()).get()
                let keyPair = try NaclSign.KeyPair.keyPair(fromSeed: keys.key)
                let newKey = try PublicKey(data: keyPair.publicKey)

                publicKey = newKey
                secretKey = keyPair.secretKey
            }

            return .init(phrase: [seed], publicKey: publicKey, secretKey: secretKey)
        }.value
    }

    public init(mnemonic: Mnemonic, network: Network, derivablePath: DerivablePath) async throws {
        self = try await Task {
            let phrase = mnemonic.phrase

            let publicKey: PublicKey
            let secretKey: Data

            switch derivablePath.type {
            case .deprecated:
                let keychain = try Keychain(seedString: phrase.joined(separator: " "), network: network.cluster)
                guard let seed = try keychain?.derivedKeychain(at: derivablePath.rawValue).privateKey else {
                    throw KeyPairError.couldNotDerivatePrivateKey
                }

                let keys = try NaclSign.KeyPair.keyPair(fromSeed: seed)

                publicKey = try .init(data: keys.publicKey)
                secretKey = keys.secretKey
            default:
                let keys = try Ed25519HDKey.derivePath(derivablePath.rawValue, seed: mnemonic.seed.toHexString()).get()
                let keyPair = try NaclSign.KeyPair.keyPair(fromSeed: keys.key)
                let newKey = try PublicKey(data: keyPair.publicKey)

                publicKey = newKey
                secretKey = keyPair.secretKey
            }

            return .init(phrase: phrase, publicKey: publicKey, secretKey: secretKey)
        }.value
    }

    /// Create account with seed phrase
    /// - Parameters:
    ///   - phrase: secret phrase for an account, leave it empty for new account
    ///   - network: network in which account should be created
    /// - Throws: Error if the derivation is not successful
    public init(phrase: [String] = [], network: Network, derivablePath: DerivablePath? = nil) async throws {
        let mnemonic: Mnemonic
        var phrase = phrase.filter { !$0.isEmpty }
        if !phrase.isEmpty {
            mnemonic = try Mnemonic(phrase: phrase)
        } else {
            // change from 12-words to 24-words (128 to 256)
            mnemonic = Mnemonic()
            phrase = mnemonic.phrase
        }

        var derivablePath = derivablePath
        if derivablePath == nil {
            if phrase.count == 12 {
                derivablePath = .init(type: .deprecated, walletIndex: 0, accountIndex: 0)
            } else {
                derivablePath = .default
            }
        }

        let publicKey: PublicKey
        let secretKey: Data

        switch derivablePath!.type {
        case .deprecated:
            let keychain = try Keychain(seedString: phrase.joined(separator: " "), network: network.cluster)
            guard let seed = try keychain?.derivedKeychain(at: derivablePath!.rawValue).privateKey else {
                throw KeyPairError.couldNotDerivatePrivateKey
            }

            let keys = try NaclSign.KeyPair.keyPair(fromSeed: seed)

            publicKey = try .init(data: keys.publicKey)
            secretKey = keys.secretKey
        default:
            let keys = try Ed25519HDKey.derivePath(derivablePath!.rawValue, seed: mnemonic.seed.toHexString()).get()
            let keyPair = try NaclSign.KeyPair.keyPair(fromSeed: keys.key)
            let newKey = try PublicKey(data: keyPair.publicKey)

            publicKey = newKey
            secretKey = keyPair.secretKey
        }

        self.phrase = phrase
        self.publicKey = publicKey
        self.secretKey = secretKey
    }
}
