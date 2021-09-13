//
//  RenVM+SolanaChain+RenProgram.swift
//  SolanaSwift
//
//  Created by Chung Tran on 13/09/2021.
//

import Foundation

private extension SolanaSDK.PublicKey {
    static let sysvarInstruction: SolanaSDK.PublicKey = "Sysvar1nstructions1111111111111111111111111"
    static let secp256k1ProgramId: SolanaSDK.PublicKey = "KeccakSecp256k11111111111111111111111111111"
}

extension RenVM.SolanaChain {
    struct RenProgram {
        static let ETHEREUM_ADDRESS_BYTES = 20
        static let SIGNATURE_OFFSETS_SERIALIZED_SIZE = 11
        static let SECP256K1_INSTRUCTION_SIZE = 98
        
        public static func mintInstruction(
            account: SolanaSDK.PublicKey,
            gatewayAccount: SolanaSDK.PublicKey,
            tokenMint: SolanaSDK.PublicKey,
            recipientTokenAccount: SolanaSDK.PublicKey,
            mintLogAccount: SolanaSDK.PublicKey,
            mintAuthority: SolanaSDK.PublicKey,
            programId: SolanaSDK.PublicKey
        ) -> SolanaSDK.TransactionInstruction {
            .init(
                keys: [
                    .init(publicKey: account, isSigner: true, isWritable: false),
                    .init(publicKey: gatewayAccount, isSigner: false, isWritable: false),
                    .init(publicKey: tokenMint, isSigner: false, isWritable: true),
                    .init(publicKey: recipientTokenAccount, isSigner: false, isWritable: true),
                    .init(publicKey: mintLogAccount, isSigner: false, isWritable: true),
                    .init(publicKey: mintAuthority, isSigner: false, isWritable: false),
                    .init(publicKey: .programId, isSigner: false, isWritable: false),
                    .init(publicKey: .sysvarInstruction, isSigner: false, isWritable: false),
                    .init(publicKey: .sysvarRent, isSigner: false, isWritable: false),
                    .init(publicKey: .tokenProgramId, isSigner: false, isWritable: false)
                ],
                programId: programId,
                data: [UInt8(1)]
            )
        }
        
        public static func createInstructionWithEthAddress2(
            ethAddress: Data,
            message: Data,
            signature: Data,
            recoveryId: UInt8
        ) -> SolanaSDK.TransactionInstruction {
            let dataStart = 1 + SIGNATURE_OFFSETS_SERIALIZED_SIZE
            let ethAddressOffset = dataStart + 1
            let signatureOffset = ethAddressOffset + ETHEREUM_ADDRESS_BYTES
            let messageDataOffset = signatureOffset + signature.count + 1
            let numSignatures = 1
            
            var data = Data()
            data += [UInt8(numSignatures)]
            data += UInt16(signatureOffset).bytesLE
            data += [UInt8(1)]
            data += UInt16(ethAddressOffset).bytesLE
            data += [UInt8(1)]
            data += UInt16(messageDataOffset).bytesLE
            data += UInt16(message.count).bytesLE
            data += [UInt8(1)]
            data += [UInt8(0)]
            data += ethAddress
            data += signature
            data += [recoveryId]
            data += message
            
            return .init(keys: [], programId: .secp256k1ProgramId, data: data.bytes)
        }
    }
}
