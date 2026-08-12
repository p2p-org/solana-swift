import Foundation
import P256K

struct CKSecp256k1 {

    // MARK: - Public key from private key
    // Returns compressed (33-byte) or uncompressed (65-byte) pubkey bytes.

    static func generatePublicKey(withPrivateKey privateKeyBytes: Data,
                                  compression: Bool) throws -> Data {
        let privKey = try P256K.Signing.PrivateKey(dataRepresentation: privateKeyBytes)
        if compression {
            // format: .compressed → dataRepresentation returns 33 bytes
            return privKey.publicKey.dataRepresentation
        } else {
            return privKey.publicKey.uncompressedRepresentation
        }
    }

    // MARK: - Sign — returns 64-byte compact (r || s)

    static func sign(message: Data, with privateKeyBytes: Data) throws -> Data {
        let privKey = try P256K.Signing.PrivateKey(dataRepresentation: privateKeyBytes)
        let sig = try privKey.signature(for: message)
        return sig.compactRepresentation
    }

    // MARK: - Verify

    static func verify(signature signatureData: Data,
                       message messageData: Data,
                       publicKeyData: Data) throws -> Bool {
        let format: P256K.Format = publicKeyData.count == 33 ? .compressed : .uncompressed
        guard publicKeyData.count == 33 || publicKeyData.count == 65 else {
            throw CKSecp256k1Error.invalidPublicKeyLength
        }
        let pubKey = try P256K.Signing.PublicKey(dataRepresentation: publicKeyData,
                                                  format: format)
        let sig = try P256K.Signing.ECDSASignature(compactRepresentation: signatureData)
        return pubKey.isValidSignature(sig, for: messageData)
    }
}

enum CKSecp256k1Error: Error {
    case invalidPublicKeyLength
}
