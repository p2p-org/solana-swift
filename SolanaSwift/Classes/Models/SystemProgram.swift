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
        private static let PROGRAM_INDEX_TRANSFER = UInt32(2)
        
        public static func transfer(from fromPublicKey: PublicKey, to toPublicKey: PublicKey, lamports: Int64) -> Instruction {
            var keys = [Account.Meta]()
            keys.append(Account.Meta(publicKey: fromPublicKey, isSigner: true, isWritable: true))
            keys.append(Account.Meta(publicKey: toPublicKey, isSigner: false, isWritable: true))
            
            // 4 byte instruction index + 8 bytes lamports
            var data = Data()
            data.append(contentsOf: SystemProgram.PROGRAM_INDEX_TRANSFER.bytes)
            let array = withUnsafeBytes(of: lamports.littleEndian, Array.init)
            data.append(contentsOf: array)
            return Instruction(keys: keys, programId: SystemProgram.PROGRAM_ID, data: data.bytes)
        }
        
        public struct Instruction: Decodable {
            public let keys: [SolanaSDK.Account.Meta]
            public let programId: SolanaSDK.PublicKey
            public let data: [UInt8]
        }
        
    }
}
