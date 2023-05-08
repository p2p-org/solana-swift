import Foundation

public struct AccountInstructions {
    public init(
        account: PublicKey,
        instructions: [TransactionInstruction] = [],
        cleanupInstructions: [TransactionInstruction] = [],
        signers: [KeyPair] = [],
        newTokenAccountPubkey: String?,
        secretKey: Data? = nil
    ) {
        self.account = account
        self.instructions = instructions
        self.cleanupInstructions = cleanupInstructions
        self.signers = signers
        self.newTokenAccountPubkey = newTokenAccountPubkey
        self.secretKey = secretKey
    }

    public let account: PublicKey
    public var instructions: [TransactionInstruction]
    public var cleanupInstructions: [TransactionInstruction]
    public let signers: [KeyPair]

    // additionally return new token account address
    internal private(set) var newTokenAccountPubkey: String?

    // additionally return newAccount's secretkey
    internal private(set) var secretKey: Data?
}
