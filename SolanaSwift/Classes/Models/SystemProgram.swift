//
//  SystemProgram.swift
//  SolanaSwift
//
//  Created by Chung Tran on 11/6/20.
//

import Foundation

public extension SolanaSDK {
    struct SystemProgram {
        // MARK: - Constraint
        public static let programId = try! PublicKey(string: "11111111111111111111111111111111")
        
        // MARK: - Instructions
        public static func createAccount(
            from fromPublicKey: PublicKey,
            toNewPubkey newPubkey: PublicKey,
            lamports: UInt64,
            programPubkey: PublicKey,
            space: UInt64 = AccountLayout.span
        ) -> Transaction.Instruction
        {
            var keys = [Account.Meta]()
            keys.append(Account.Meta(publicKey: fromPublicKey, isSigner: true, isWritable: true))
            keys.append(Account.Meta(publicKey: newPubkey, isSigner: true, isWritable: true))
            
            let data = SystemProgram.Instruction.create.encode([
                lamports,
                space,
                programPubkey
            ])
            return Transaction.Instruction(keys: keys, programId: programId, data: data.bytes)
        }
        
        public static func transfer(from fromPublicKey: PublicKey, to toPublicKey: PublicKey, lamports: UInt64) -> Transaction.Instruction {
            var keys = [Account.Meta]()
            keys.append(Account.Meta(publicKey: fromPublicKey, isSigner: true, isWritable: true))
            keys.append(Account.Meta(publicKey: toPublicKey, isSigner: false, isWritable: true))
            
            let data = SystemProgram.Instruction.transfer.encode([
                lamports
            ])
            return Transaction.Instruction(keys: keys, programId: programId, data: data.bytes)
        }
    }
}

extension SolanaSDK.SystemProgram {
    // MARK: - Nested types
    fileprivate enum Instruction: UInt32 {
        case create                 = 0
        case assign                 = 1
        case transfer               = 2
        case createWithSeed         = 3
        case advanceNonceAccount    = 4
        case withdrawNonceAccount   = 5
        case initializeNonceAccount = 6
        case authorizeNonceAccount  = 7
        case allocate               = 8
        case allocateWithSeed       = 9
        case sssignWithSeed         = 10
        
        private var indexBytes: [UInt8] {
            rawValue.bytes
        }
        
        fileprivate func encode(_ array: [InstructionEncodable]) -> Data {
            var data = Data()
            data.append(contentsOf: indexBytes)
            for el in array {
                data.append(contentsOf: el.instructionEncode())
            }
            return data
        }
    }
}

fileprivate protocol InstructionEncodable {
    func instructionEncode() -> [UInt8]
}

extension UInt64: InstructionEncodable {
    fileprivate func instructionEncode() -> [UInt8] {
        withUnsafeBytes(of: littleEndian, Array.init)
    }
}

extension SolanaSDK.PublicKey: InstructionEncodable {
    fileprivate func instructionEncode() -> [UInt8] {
        bytes
    }
}

