//
//  SystemProgram.swift
//  SolanaSwift
//
//  Created by Chung Tran on 11/6/20.
//

import Foundation

extension SolanaSDK {
    struct SystemProgram {
        public static let PROGRAM_ID = try! PublicKey(string: "11111111111111111111111111111111")
        private static let PROGRAM_INDEX_TRANSFER = UInt32(2)
        
        public static func transfer(from fromPublicKey: PublicKey, to toPublicKey: PublicKey, lamports: UInt64) -> Transaction.Instruction {
            var keys = [Account.Meta]()
            keys.append(Account.Meta(publicKey: fromPublicKey, isSigner: true, isWritable: true))
            keys.append(Account.Meta(publicKey: toPublicKey, isSigner: false, isWritable: false))
            
            // 4 byte instruction index + 8 bytes lamports
            var data = Data(capacity: 12)
            data.append(contentsOf: SystemProgram.PROGRAM_INDEX_TRANSFER.bytes)
            data.append(contentsOf: lamports.bytes)
            return Transaction.Instruction(keys: keys, programId: SystemProgram.PROGRAM_ID, data: data.bytes)
        }
    }
}
