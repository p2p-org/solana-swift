//
//  SystemProgram.swift
//  SolanaSwift
//
//  Created by Chung Tran on 11/6/20.
//

import Foundation

public extension SolanaSDK {
    struct SystemProgram {
        public static let PROGRAM_ID = try! PublicKey(string: "11111111111111111111111111111111")
        private static let PROGRAM_INDEX_CREATE = UInt32(2)
        private static let PROGRAM_INDEX_TRANSFER = UInt32(2)
        
        public static func transfer(from fromPublicKey: PublicKey, to toPublicKey: PublicKey, lamports: Int64) -> Transaction.Instruction {
            var keys = [Account.Meta]()
            keys.append(Account.Meta(publicKey: fromPublicKey, isSigner: true, isWritable: true))
            keys.append(Account.Meta(publicKey: toPublicKey, isSigner: false, isWritable: true))
            
            // 4 byte instruction index + 8 bytes lamports
            var data = Data()
            data.append(contentsOf: SystemProgram.PROGRAM_INDEX_TRANSFER.bytes)
            let array = withUnsafeBytes(of: lamports.littleEndian, Array.init)
            data.append(contentsOf: array)
            return Transaction.Instruction(keys: keys, programId: SystemProgram.PROGRAM_ID, data: data.bytes)
        }
        
        public static func createAccount(from fromPublicKey: PublicKey, toNewPubkey newPubkey: PublicKey, lamports: Int64, programPubkey: PublicKey, space: UInt64 = AccountLayout.span) -> Transaction.Instruction
        {
            var keys = [Account.Meta]()
            keys.append(Account.Meta(publicKey: fromPublicKey, isSigner: true, isWritable: true))
            keys.append(Account.Meta(publicKey: newPubkey, isSigner: true, isWritable: true))
            
            // 4 byte instruction index + 8 bytes lamports
            var data = Data()
            data.append(contentsOf: SystemProgram.PROGRAM_INDEX_CREATE.bytes)
            let array = withUnsafeBytes(of: lamports.littleEndian, Array.init)
            data.append(contentsOf: array)
            let space = withUnsafeBytes(of: space.littleEndian, Array.init)
            data.append(contentsOf: space)
            data.append(programPubkey.data)
            return Transaction.Instruction(keys: keys, programId: SystemProgram.PROGRAM_ID, data: data.bytes)
        }
    }
}
