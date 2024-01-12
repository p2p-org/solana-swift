import Foundation

/// The prepared transaction that can be sent or simulate in SolanaBlockchainClient
public struct PreparedVersionedTransaction: Equatable {
    public var transaction: VersionedTransaction
    public var signers: [KeyPair]
    public var expectedFee: FeeAmount

    public init(transaction: VersionedTransaction, signers: [KeyPair], expectedFee: FeeAmount) {
        self.transaction = transaction
        self.signers = signers
        self.expectedFee = expectedFee
    }

    public init(
        legacyTransaction transaction: Transaction,
        signers: [KeyPair],
        expectedFee: FeeAmount
    ) throws {
        self.transaction = try .init(message: .legacy(transaction.compileMessage()))
        self.signers = signers
        self.expectedFee = expectedFee
    }

    public mutating func sign() throws {
        try transaction.sign(signers: signers)
    }

    public func serialize() throws -> String {
        let serializedTransaction = try transaction.serialize().bytes.toBase64()
        #if DEBUG
            Logger.log(event: "serializedTransaction", message: serializedTransaction, logLevel: .debug)
            Logger.log(event: "decodedTransaction", message: String(reflecting: transaction), logLevel: .debug)
        #endif
        return serializedTransaction
    }
}

extension PreparedVersionedTransaction: PreparedTransactionType {
    public mutating func setRecentBlockHash(_ blockHash: BlockHash) {
        transaction.setRecentBlockHash(blockHash)
    }
}
