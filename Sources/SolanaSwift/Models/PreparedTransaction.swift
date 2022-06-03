import Foundation

public struct PreparedTransaction {
    public init(transaction: Transaction, signers: [Account], expectedFee: FeeAmount) {
        self.transaction = transaction
        self.signers = signers
        self.expectedFee = expectedFee
    }

    public var transaction: Transaction
    public var signers: [Account]
    public var expectedFee: FeeAmount

    public mutating func sign() throws {
        try transaction.sign(signers: signers)
    }

    public func serialize() throws -> String {
        var transaction = transaction
        let serializedTransaction = try transaction.serialize().bytes.toBase64()
        #if DEBUG
            Logger.log(event: .info, message: serializedTransaction)
            if let decodedTransaction = transaction.jsonString {
                Logger.log(event: .info, message: decodedTransaction)
            }
        #endif
        return serializedTransaction
    }

    public func findSignature(publicKey: PublicKey) throws -> String {
        guard let signature = transaction.findSignature(pubkey: publicKey)?.signature
        else {
            throw SolanaError.other("Signature not found")
        }
        return Base58.encode(signature.bytes)
    }
}
