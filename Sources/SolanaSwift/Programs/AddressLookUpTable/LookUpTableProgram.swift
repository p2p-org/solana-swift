import Foundation

public enum LookUpTableProgram {
    public static var id: PublicKey {
        "AddressLookupTab1e1111111111111111111111111"
    }

    public static func createLookupTable(
        authority: PublicKey,
        payer: PublicKey,
        recentSlot: UInt64
    ) throws -> (TransactionInstruction, PublicKey) {
        let (lookupTableAddress, bump) = try PublicKey.findProgramAddress(
            seeds: [
                authority.data,
                Data(recentSlot.bytes),
            ],
            programId: id
        )

        return (
            TransactionInstruction(
                keys: [
                    .init(publicKey: lookupTableAddress, isSigner: false, isWritable: true),
                    .init(publicKey: authority, isSigner: true, isWritable: false),
                    .init(publicKey: payer, isSigner: true, isWritable: true),
                    .init(publicKey: SystemProgram.id, isSigner: false, isWritable: false),
                ],
                programId: id,
                data: [
                    UInt32(0),
                    recentSlot,
                    bump,
                ]
            ),
            lookupTableAddress
        )
    }

    public static func extendLookupTable(
        lookupTable: PublicKey,
        authority: PublicKey,
        payer: PublicKey?,
        addresses: [PublicKey]
    ) -> TransactionInstruction {
        var keys: [AccountMeta] = [
            .init(publicKey: lookupTable, isSigner: false, isWritable: true),
            .init(publicKey: authority, isSigner: true, isWritable: false),
        ]

        if let payer = payer {
            keys.append(contentsOf: [
                .init(publicKey: payer, isSigner: true, isWritable: true),
                .init(publicKey: SystemProgram.id, isSigner: false, isWritable: false),
            ])
        }

        return TransactionInstruction(
            keys: keys,
            programId: id,
            data: [
                UInt32(2),
                UInt64(addresses.count),
                addresses.map { $0.bytes }.reduce([], +),
            ]
        )
    }

    public static func closeLookupTable(
        lookupTable: PublicKey,
        authority: PublicKey,
        recipient: PublicKey
    ) -> TransactionInstruction {
        return TransactionInstruction(
            keys: [
                .init(publicKey: lookupTable, isSigner: false, isWritable: true),
                .init(publicKey: authority, isSigner: true, isWritable: false),
                .init(publicKey: recipient, isSigner: false, isWritable: true),
            ],
            programId: id,
            data: [UInt32(4)]
        )
    }
}
