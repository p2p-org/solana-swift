import Foundation

protocol SolanaOwnerValidationProgram: SolanaBasicProgram {
    func assertOwnerInstruction(
        account: PublicKey,
        programId: PublicKey
    ) -> TransactionInstruction
}

public struct OwnerValidationProgram: SolanaOwnerValidationProgram {
    public var id: PublicKey {
        "4MNPdKu9wFMvEeZBMt3Eipfs5ovVWTJb31pEXDJAAxX5"
    }
    
    public init() {}
    
    public func assertOwnerInstruction(
        account: PublicKey,
        programId: PublicKey
    ) -> TransactionInstruction {
        TransactionInstruction(
            keys: [
                Account.Meta(publicKey: account, isSigner: false, isWritable: false)
            ],
            programId: OwnerValidationProgram().id,
            data: [programId]
        )
    }
}
