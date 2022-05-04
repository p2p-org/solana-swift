import Foundation

public protocol AssociatedTokenProgramType {
    func createAssociatedTokenAccountInstruction(
        mint: PublicKey,
        owner: PublicKey,
        payer: PublicKey
    ) throws -> TransactionInstruction
}

public struct AssociatedTokenProgram: SolanaBasicProgramType, AssociatedTokenProgramType {
    // MARK: - Properties
    public var id: PublicKey {
        "ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL"
    }
    
    // MARK: - Initializer
    public init() {}
    
    // MARK: - Instruction builder
    public func createAssociatedTokenAccountInstruction(
        mint: PublicKey,
        owner: PublicKey,
        payer: PublicKey
    ) throws -> TransactionInstruction {
        TransactionInstruction(
            keys: [
                .init(publicKey: payer, isSigner: true, isWritable: true),
                .init(
                    publicKey: try PublicKey.associatedTokenAddress(
                        walletAddress: owner,
                        tokenMintAddress: mint
                    ),
                    isSigner: false,
                    isWritable: true
                ),
                .init(publicKey: owner, isSigner: false, isWritable: false),
                .init(publicKey: mint, isSigner: false, isWritable: false),
                .init(publicKey: SystemProgram().id, isSigner: false, isWritable: false),
                .init(publicKey: TokenProgram().id, isSigner: false, isWritable: false),
                .init(publicKey: .sysvarRent, isSigner: false, isWritable: false)
            ],
            programId: id,
            data: []
        )
    }
}
