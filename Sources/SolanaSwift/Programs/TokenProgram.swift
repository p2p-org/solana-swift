import Foundation

public enum TokenProgram: SolanaBasicProgram {
    // MARK: - Nested type

    public enum Index {
        static let initalizeMint: UInt8 = 0
        static let initializeAccount: UInt8 = 1
        static let transfer: UInt8 = 3
        static let approve: UInt8 = 4
        static let mintTo: UInt8 = 7
        static let closeAccount: UInt8 = 9
        static let transferChecked: UInt8 = 12
        static let burnChecked: UInt8 = 15
    }

    // MARK: - Properties

    public static var id: PublicKey {
        "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA"
    }

    // MARK: - Instruction builders

    public static func initializeMintInstruction(
        mint: PublicKey,
        decimals: UInt8,
        authority: PublicKey,
        freezeAuthority: PublicKey?
    ) -> TransactionInstruction {
        TransactionInstruction(
            keys: [
                AccountMeta(publicKey: mint, isSigner: false, isWritable: true),
                AccountMeta(publicKey: PublicKey.sysvarRent, isSigner: false, isWritable: false),
            ],
            programId: TokenProgram.id,
            data: [
                Index.initalizeMint,
                decimals,
                authority,
                freezeAuthority != nil,
                freezeAuthority?.bytes ?? Data(capacity: PublicKey.numberOfBytes).bytes,
            ]
        )
    }

    public static func initializeAccountInstruction(
        account: PublicKey,
        mint: PublicKey,
        owner: PublicKey
    ) -> TransactionInstruction {
        TransactionInstruction(
            keys: [
                AccountMeta(publicKey: account, isSigner: false, isWritable: true),
                AccountMeta(publicKey: mint, isSigner: false, isWritable: false),
                AccountMeta(publicKey: owner, isSigner: false, isWritable: false),
                AccountMeta(publicKey: PublicKey.sysvarRent, isSigner: false, isWritable: false),
            ],
            programId: TokenProgram.id,
            data: [Index.initializeAccount]
        )
    }

    public static func transferInstruction(
        source: PublicKey,
        destination: PublicKey,
        owner: PublicKey,
        amount: UInt64
    ) -> TransactionInstruction {
        TransactionInstruction(
            keys: [
                AccountMeta(publicKey: source, isSigner: false, isWritable: true),
                AccountMeta(publicKey: destination, isSigner: false, isWritable: true),
                AccountMeta(publicKey: owner, isSigner: true, isWritable: true),
            ],
            programId: TokenProgram.id,
            data: [Index.transfer, amount]
        )
    }

    public static func transferCheckedInstruction(
        source: PublicKey,
        mint: PublicKey,
        destination: PublicKey,
        owner: PublicKey,
        multiSigners: [PublicKey],
        amount: Lamports,
        decimals: Decimals
    ) -> TransactionInstruction {
        var keys = [
            AccountMeta(publicKey: source, isSigner: false, isWritable: true),
            AccountMeta(publicKey: mint, isSigner: false, isWritable: false),
            AccountMeta(publicKey: destination, isSigner: false, isWritable: true),
        ]

        if multiSigners.isEmpty {
            keys.append(.init(publicKey: owner, isSigner: true, isWritable: false))
        } else {
            keys.append(.init(publicKey: owner, isSigner: false, isWritable: false))
            multiSigners.forEach { signer in
                keys.append(.init(publicKey: signer, isSigner: true, isWritable: false))
            }
        }

        return .init(
            keys: keys,
            programId: TokenProgram.id,
            data: [Index.transferChecked, amount, decimals]
        )
    }

    public static func burnCheckedInstruction(
        mint: PublicKey,
        account: PublicKey,
        owner: PublicKey,
        amount: UInt64,
        decimals: UInt8
    ) -> TransactionInstruction {
        .init(
            keys: [
                .init(publicKey: account, isSigner: false, isWritable: true),
                .init(publicKey: mint, isSigner: false, isWritable: true),
                .init(publicKey: owner, isSigner: true, isWritable: false),
            ],
            programId: TokenProgram.id,
            data: [
                Index.burnChecked,
                amount,
                decimals,
            ]
        )
    }

    public static func approveInstruction(
        account: PublicKey,
        delegate: PublicKey,
        owner: PublicKey,
        multiSigners: [KeyPair],
        amount: UInt64
    ) -> TransactionInstruction {
        var keys = [
            AccountMeta(publicKey: account, isSigner: false, isWritable: true),
            AccountMeta(publicKey: delegate, isSigner: false, isWritable: false),
        ]

        if multiSigners.isEmpty {
            keys.append(
                AccountMeta(publicKey: owner, isSigner: true, isWritable: false)
            )
        } else {
            keys.append(
                AccountMeta(publicKey: owner, isSigner: false, isWritable: false)
            )

            for signer in multiSigners {
                keys.append(
                    AccountMeta(publicKey: signer.publicKey, isSigner: true, isWritable: false)
                )
            }
        }

        return TransactionInstruction(
            keys: keys,
            programId: TokenProgram.id,
            data: [Index.approve, amount]
        )
    }

    public static func mintToInstruction(
        mint: PublicKey,
        destination: PublicKey,
        authority: PublicKey,
        amount: UInt64
    ) -> TransactionInstruction {
        TransactionInstruction(
            keys: [
                AccountMeta(publicKey: mint, isSigner: false, isWritable: true),
                AccountMeta(publicKey: destination, isSigner: false, isWritable: true),
                AccountMeta(publicKey: authority, isSigner: true, isWritable: true),
            ],
            programId: TokenProgram.id,
            data: [Index.mintTo, amount]
        )
    }

    public static func closeAccountInstruction(
        account: PublicKey,
        destination: PublicKey,
        owner: PublicKey
    ) -> TransactionInstruction {
        .init(
            keys: [
                AccountMeta(publicKey: account, isSigner: false, isWritable: true),
                AccountMeta(publicKey: destination, isSigner: false, isWritable: true),
                AccountMeta(publicKey: owner, isSigner: false, isWritable: false),
            ],
            programId: TokenProgram.id,
            data: [Index.closeAccount]
        )
    }

    public static func closeAccountInstruction(
        account: PublicKey,
        destination: PublicKey,
        owner: PublicKey,
        signers: [PublicKey]
    ) -> TransactionInstruction {
        .init(
            keys: [
                .writable(publicKey: account, isSigner: false),
                .writable(publicKey: destination, isSigner: false),
                .readonly(publicKey: owner, isSigner: signers.isEmpty),
            ] + signers.map { .readonly(publicKey: $0, isSigner: true) },
            programId: TokenProgram.id,
            data: [Index.closeAccount]
        )
    }
}
