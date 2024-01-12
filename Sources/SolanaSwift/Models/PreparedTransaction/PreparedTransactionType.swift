import Foundation

public protocol PreparedTransactionType {
    var expectedFee: FeeAmount { get }
    init(legacyTransaction transaction: Transaction, signers: [KeyPair], expectedFee: FeeAmount) throws
    mutating func sign() throws
    mutating func setRecentBlockHash(_ blockHash: BlockHash)
    func serialize() throws -> String
}
