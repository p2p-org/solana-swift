import Foundation

public protocol TokenProgramType {
    func initializeMintInstruction(
        mint: PublicKey,
        decimals: UInt8,
        authority: PublicKey,
        freezeAuthority: PublicKey?
    ) -> TransactionInstruction
    
    func initializeAccountInstruction(
        account: PublicKey,
        mint: PublicKey,
        owner: PublicKey
    ) -> TransactionInstruction
    
    func transferInstruction(
        source: PublicKey,
        destination: PublicKey,
        owner: PublicKey,
        amount: UInt64
    ) -> TransactionInstruction
    
    func transferCheckedInstruction(
        source: PublicKey,
        mint: PublicKey,
        destination: PublicKey,
        owner: PublicKey,
        multiSigners: [Account],
        amount: Lamports,
        decimals: Decimals
    ) -> TransactionInstruction
    
    func burnCheckedInstruction(
        mint: PublicKey,
        account: PublicKey,
        owner: PublicKey,
        amount: UInt64,
        decimals: UInt8
    ) -> TransactionInstruction
    
    func approveInstruction(
        account: PublicKey,
        delegate: PublicKey,
        owner: PublicKey,
        multiSigners: [Account],
        amount: UInt64
    ) -> TransactionInstruction
    
    func mintToInstruction(
        mint: PublicKey,
        destination: PublicKey,
        authority: PublicKey,
        amount: UInt64
    ) -> TransactionInstruction
    
    func closeAccountInstruction(
        account: PublicKey,
        destination: PublicKey,
        owner: PublicKey
    ) -> TransactionInstruction
    
    func closeAccountInstruction(
        account: PublicKey,
        destination: PublicKey,
        owner: PublicKey,
        signers: [PublicKey]
    ) -> TransactionInstruction
}

public struct TokenProgram: SolanaBasicProgramType {
    // MARK: - Nested type
    private struct Index {
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
    public var id: PublicKey {
        "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA"
    }
    
    // MARK: - Initializer
    public init() {}
    
    // MARK: - Instruction builders
    public func initializeMintInstruction(
        mint: PublicKey,
        decimals: UInt8,
        authority: PublicKey,
        freezeAuthority: PublicKey?
    ) -> TransactionInstruction {
        
        TransactionInstruction(
            keys: [
                Account.Meta(publicKey: mint, isSigner: false, isWritable: true),
                Account.Meta(publicKey: PublicKey.sysvarRent, isSigner: false, isWritable: false)
            ],
            programId: id,
            data: [
                Index.initalizeMint,
                decimals,
                authority,
                freezeAuthority != nil,
                freezeAuthority?.bytes ?? Data(capacity: PublicKey.numberOfBytes).bytes
            ]
        )
    }
    
    public func initializeAccountInstruction(
        account: PublicKey,
        mint: PublicKey,
        owner: PublicKey
    ) -> TransactionInstruction {
        
        TransactionInstruction(
            keys: [
                Account.Meta(publicKey: account, isSigner: false, isWritable: true),
                Account.Meta(publicKey: mint, isSigner: false, isWritable: false),
                Account.Meta(publicKey: owner, isSigner: false, isWritable: false),
                Account.Meta(publicKey: PublicKey.sysvarRent, isSigner: false, isWritable: false)
            ],
            programId: id,
            data: [Index.initializeAccount]
        )
    }
    
    public func transferInstruction(
        source: PublicKey,
        destination: PublicKey,
        owner: PublicKey,
        amount: UInt64
    ) -> TransactionInstruction {
        TransactionInstruction(
            keys: [
                Account.Meta(publicKey: source, isSigner: false, isWritable: true),
                Account.Meta(publicKey: destination, isSigner: false, isWritable: true),
                Account.Meta(publicKey: owner, isSigner: true, isWritable: true)
            ],
            programId: id,
            data: [Index.transfer, amount]
        )
    }
    
    public func transferCheckedInstruction(
        source: PublicKey,
        mint: PublicKey,
        destination: PublicKey,
        owner: PublicKey,
        multiSigners: [PublicKey],
        amount: Lamports,
        decimals: Decimals
    ) -> TransactionInstruction {
        var keys = [
            Account.Meta(publicKey: source, isSigner: false, isWritable: true),
            Account.Meta(publicKey: mint, isSigner: false, isWritable: false),
            Account.Meta(publicKey: destination, isSigner: false, isWritable: true)
        ]
        
        if multiSigners.count == 0 {
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
            data: [Index.transferChecked, amount, decimals]
        )
    }
    
    public func burnCheckedInstruction(
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
                Index.burnChecked,
                amount,
                decimals
            ]
        )
    }
    
    public func approveInstruction(
        account: PublicKey,
        delegate: PublicKey,
        owner: PublicKey,
        multiSigners: [Account],
        amount: UInt64
    ) -> TransactionInstruction {
        var keys = [
            Account.Meta(publicKey: account, isSigner: false, isWritable: true),
            Account.Meta(publicKey: delegate, isSigner: false, isWritable: false)
        ]
        
        if multiSigners.isEmpty {
            keys.append(
                Account.Meta(publicKey: owner, isSigner: true, isWritable: false)
            )
        } else {
            keys.append(
                Account.Meta(publicKey: owner, isSigner: false, isWritable: false)
            )
            
            for signer in multiSigners {
                keys.append(
                    Account.Meta(publicKey: signer.publicKey, isSigner: true, isWritable: false)
                )
            }
        }
        
        return TransactionInstruction(
            keys: keys,
            programId: id,
            data: [Index.approve, amount]
        )
    }
    
    public func mintToInstruction(
        mint: PublicKey,
        destination: PublicKey,
        authority: PublicKey,
        amount: UInt64
    ) -> TransactionInstruction {
        
        TransactionInstruction(
            keys: [
                Account.Meta(publicKey: mint, isSigner: false, isWritable: true),
                Account.Meta(publicKey: destination, isSigner: false, isWritable: true),
                Account.Meta(publicKey: authority, isSigner: true, isWritable: true)
            ],
            programId: id,
            data: [Index.mintTo, amount]
        )
    }
    
    public func closeAccountInstruction(
        account: PublicKey,
        destination: PublicKey,
        owner: PublicKey
    ) -> TransactionInstruction {
        .init(
            keys: [
                Account.Meta(publicKey: account, isSigner: false, isWritable: true),
                Account.Meta(publicKey: destination, isSigner: false, isWritable: true),
                Account.Meta(publicKey: owner, isSigner: false, isWritable: false)
            ],
            programId: id,
            data: [Index.closeAccount]
        )
    }
    
    public func closeAccountInstruction(
        account: PublicKey,
        destination: PublicKey,
        owner: PublicKey,
        signers: [PublicKey]
    ) -> TransactionInstruction {
        .init(
            keys: [
                .writable(publicKey: account, isSigner: false),
                .writable(publicKey: destination, isSigner: false),
                .readonly(publicKey: owner, isSigner: signers.isEmpty)
            ] + signers.map {.readonly(publicKey: $0, isSigner: true)},
            programId: id,
            data: [Index.closeAccount])
    }
}
