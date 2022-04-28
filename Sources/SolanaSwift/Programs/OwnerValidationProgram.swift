import Foundation

protocol OwnerValidationProgramType: SolanaBasicProgramType {
    func assertOwnerInstruction(
        account: PublicKey,
        programId: PublicKey
    ) -> TransactionInstruction
}

public struct OwnerValidationProgram: OwnerValidationProgramType {
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
            programId: id,
            data: [programId]
        )
    }
}
