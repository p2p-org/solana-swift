import Foundation

public enum OwnerValidationProgram: SolanaBasicProgram {
    public static var id: PublicKey {
        "4MNPdKu9wFMvEeZBMt3Eipfs5ovVWTJb31pEXDJAAxX5"
    }

    public static func assertOwnerInstruction(
        account: PublicKey,
        programId: PublicKey
    ) -> TransactionInstruction {
        TransactionInstruction(
            keys: [
                AccountMeta(publicKey: account, isSigner: false, isWritable: false),
            ],
            programId: OwnerValidationProgram.id,
            data: [programId]
        )
    }
}
