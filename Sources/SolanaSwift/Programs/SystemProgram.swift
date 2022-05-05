import Foundation

public enum SystemProgram: SolanaBasicProgram {
    // MARK: - Nested type
    public struct Index {
        static let create: UInt32 = 0
        static let transfer: UInt32 = 2
    }
    
    // MARK: - Properties
    public static var id: PublicKey {
        "11111111111111111111111111111111"
    }
    
    // MARK: - Instruction builders
    public static func createAccountInstruction(
        from fromPublicKey: PublicKey,
        toNewPubkey newPubkey: PublicKey,
        lamports: UInt64,
        space: UInt64
    ) -> TransactionInstruction {
        
        TransactionInstruction(
            keys: [
                Account.Meta(publicKey: fromPublicKey, isSigner: true, isWritable: true),
                Account.Meta(publicKey: newPubkey, isSigner: true, isWritable: true)
            ],
            programId: SystemProgram.id,
            data: [Index.create, lamports, space, SystemProgram.id]
        )
    }
    
    public static func transferInstruction(
        from fromPublicKey: PublicKey,
        to toPublicKey: PublicKey,
        lamports: UInt64
    ) -> TransactionInstruction {
        
        TransactionInstruction(
            keys: [
                Account.Meta(publicKey: fromPublicKey, isSigner: true, isWritable: true),
                Account.Meta(publicKey: toPublicKey, isSigner: false, isWritable: true)
            ],
            programId: SystemProgram.id,
            data: [Index.transfer, lamports]
        )
    }
}
