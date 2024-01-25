import Foundation

public protocol SolanaTokenProgram: SolanaBasicProgram {}

public extension SolanaTokenProgram {
    static var initalizeMintIndex: UInt8 { 0 }
    static var initializeAccountIndex: UInt8 { 1 }
    static var transferIndex: UInt8 { 3 }
    static var approveIndex: UInt8 { 4 }
    static var mintToIndex: UInt8 { 7 }
    static var closeAccountIndex: UInt8 { 9 }
    static var transferCheckedIndex: UInt8 { 12 }
    static var burnCheckedIndex: UInt8 { 15 }

    static func initializeMintInstruction(
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
            programId: id,
            data: [
                initalizeMintIndex,
                decimals,
                authority,
                freezeAuthority != nil,
                freezeAuthority?.bytes ?? Data(capacity: PublicKey.numberOfBytes).bytes,
            ]
        )
    }

    static func initializeAccountInstruction(
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
            programId: id,
            data: [initializeAccountIndex]
        )
    }

    static func transferInstruction(
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
            programId: id,
            data: [transferIndex, amount]
        )
    }

    static func transferCheckedInstruction(
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
            programId: id,
            data: [transferCheckedIndex, amount, decimals]
        )
    }

    static func burnCheckedInstruction(
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
            programId: id,
            data: [
                burnCheckedIndex,
                amount,
                decimals,
            ]
        )
    }

    static func approveInstruction(
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
            programId: id,
            data: [approveIndex, amount]
        )
    }

    static func mintToInstruction(
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
            programId: id,
            data: [mintToIndex, amount]
        )
    }

    static func closeAccountInstruction(
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
            programId: id,
            data: [closeAccountIndex]
        )
    }

    static func closeAccountInstruction(
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
            programId: id,
            data: [closeAccountIndex]
        )
    }
}
