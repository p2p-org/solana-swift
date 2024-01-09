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
        payer: PublicKey,
        tokenProgramId: PublicKey
    ) throws -> TransactionInstruction {
        try TransactionInstruction(
            keys: [
                .init(publicKey: payer, isSigner: true, isWritable: true),
                .init(
                    publicKey: PublicKey.associatedTokenAddress(
                        walletAddress: owner,
                        tokenMintAddress: mint,
                        tokenProgramId: tokenProgramId
                    ),
                    isSigner: false,
                    isWritable: true
                ),
                .init(publicKey: owner, isSigner: false, isWritable: false),
                .init(publicKey: mint, isSigner: false, isWritable: false),
                .init(publicKey: SystemProgram.id, isSigner: false, isWritable: false),
                .init(publicKey: tokenProgramId, isSigner: false, isWritable: false),
                .init(publicKey: .sysvarRent, isSigner: false, isWritable: false),
            ],
            programId: AssociatedTokenProgram.id,
            data: []
        )
    }
}
