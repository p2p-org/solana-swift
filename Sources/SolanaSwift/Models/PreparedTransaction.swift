import Foundation

/// The prepared transaction that can be sent or simulate in SolanaBlockchainClient
public struct PreparedTransaction: Equatable {
    public init(transaction: Transaction, signers: [KeyPair], expectedFee: FeeAmount) {
        self.transaction = transaction
        self.signers = signers
        self.expectedFee = expectedFee
    }

    public var transaction: Transaction
    public var signers: [KeyPair]
    public var expectedFee: FeeAmount

    public mutating func sign() throws {
        try transaction.sign(signers: signers)
    }

    public func serialize() throws -> String {
        var transaction = transaction
        let serializedTransaction = try transaction.serialize().bytes.toBase64()
        #if DEBUG
            Logger.log(event: "serializedTransaction", message: serializedTransaction, logLevel: .debug)
            if let decodedTransaction = transaction.jsonString {
                Logger.log(event: "decodedTransaction", message: decodedTransaction, logLevel: .debug)
            }
        #endif
        return serializedTransaction
    }

    public func findSignature(publicKey: PublicKey) throws -> String {
        guard let signature = transaction.findSignature(pubkey: publicKey)?.signature
        else {
            Logger.log(event: "SolanaSwift: findSignature", message: "Signature not found", logLevel: .error)
            throw VersionedTransactionError.signatureNotFound
        }
        return Base58.encode(signature.bytes)
    }
}
