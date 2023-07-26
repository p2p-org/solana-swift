import Foundation

public enum AssociatedTokenProgram: SolanaBasicProgram {
    // MARK: - Properties

    public static var id: PublicKey {
        "ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL"
    }

    // MARK: - Instruction builder

    public static func createAssociatedTokenAccountInstruction(
        mint: PublicKey,
        owner: PublicKey,
        payer: PublicKey
    ) throws -> TransactionInstruction {
        TransactionInstruction(
            keys: [
                .init(publicKey: payer, isSigner: true, isWritable: true),
                try .init(
                    publicKey: PublicKey.associatedTokenAddress(
                        walletAddress: owner,
                        tokenMintAddress: mint
                    ),
                    isSigner: false,
                    isWritable: true
                ),
                .init(publicKey: owner, isSigner: false, isWritable: false),
                .init(publicKey: mint, isSigner: false, isWritable: false),
                .init(publicKey: SystemProgram.id, isSigner: false, isWritable: false),
                .init(publicKey: TokenProgram.id, isSigner: false, isWritable: false),
                .init(publicKey: .sysvarRent, isSigner: false, isWritable: false),
            ],
            programId: AssociatedTokenProgram.id,
            data: []
        )
    }
}
