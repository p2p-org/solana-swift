//
//  SPLTokenProgram.swift
//  SolanaSwift
//
//  Created by Chung Tran on 11/6/20.
//

import Foundation

public extension SolanaSDK {
    struct SPLTokenProgram {
        // MARK: - Nested type
        private enum Index: UInt32, BytesEncodable {
            case create                 = 0
            case initializeAccount      = 1
            case transfer               = 2
            case createWithSeed         = 3
            case approve                = 4
            case withdrawNonceAccount   = 5
            case initializeNonceAccount = 6
            case mintTo                 = 7
            case allocate               = 8
            case close                  = 9
            case sssignWithSeed         = 10
        }
        
        // MARK: - Instructions
        public static func initializeMintInstruction(
            tokenProgramId: PublicKey,
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
                programId: tokenProgramId,
                data: [
                    Index.create,
                    decimals,
                    authority,
                    freezeAuthority != nil,
                    freezeAuthority?.bytes ?? Data(capacity: PublicKey.LENGTH).bytes
                ]
            )
        }
        
        public static func initializeAccountInstruction(
            programId: PublicKey = PublicKey.tokenProgramId,
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
                programId: programId,
                data: [Index.initializeAccount]
            )
        }
        
        public static func createAccountInstruction(
            from fromPublicKey: PublicKey,
            toNewPubkey newPubkey: PublicKey,
            lamports: UInt64,
            space: UInt64 = AccountLayout.span,
            programPubkey: PublicKey = PublicKey.tokenProgramId
        ) -> TransactionInstruction {
            
            TransactionInstruction(
                keys: [
                    Account.Meta(publicKey: fromPublicKey, isSigner: true, isWritable: true),
                    Account.Meta(publicKey: newPubkey, isSigner: true, isWritable: true)
                ],
                programId: PublicKey.programId,
                data: [Index.create, lamports, space, programPubkey]
            )
        }
        
        public static func transferInstruction(
            from fromPublicKey: PublicKey,
            to toPublicKey: PublicKey,
            lamports: UInt64
        ) -> TransactionInstruction {
            
            TransactionInstruction(
                keys: [
                    Account.Meta(publicKey: fromPublicKey, isSigner: true, isWritable: true),
                    Account.Meta(publicKey: toPublicKey, isSigner: false, isWritable: true)
                ],
                programId: PublicKey.programId,
                data: [Index.transfer, lamports]
            )
        }
        
        public static func approveInstruction(
            tokenProgramId: PublicKey,
            account: PublicKey,
            delegate: PublicKey,
            owner: PublicKey,
            amount: PublicKey
        ) -> TransactionInstruction {
            
            TransactionInstruction(
                keys: [
                    Account.Meta(publicKey: account, isSigner: false, isWritable: true),
                    Account.Meta(publicKey: delegate, isSigner: false, isWritable: false),
                    Account.Meta(publicKey: owner, isSigner: true, isWritable: true)
                ],
                programId: tokenProgramId,
                data: [Index.approve, amount]
            )
        }
        
        public static func mintToInstruction(
            tokenProgramId: PublicKey,
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
                programId: tokenProgramId,
                data: [Index.mintTo, amount]
            )
        }
        
        public static func closeAccountInstruction(
            tokenProgramId: PublicKey,
            account: PublicKey,
            destination: PublicKey,
            owner: PublicKey
        ) -> TransactionInstruction {
            
            TransactionInstruction(
                keys: [
                    Account.Meta(publicKey: account, isSigner: false, isWritable: true),
                    Account.Meta(publicKey: destination, isSigner: false, isWritable: true),
                    Account.Meta(publicKey: owner, isSigner: false, isWritable: false)
                ],
                programId: tokenProgramId,
                data: [Index.close]
            )
        }
    }
}
