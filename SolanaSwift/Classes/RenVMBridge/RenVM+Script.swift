//
//  RenVM+Script.swift
//  SolanaSwift
//
//  Created by Chung Tran on 10/09/2021.
//

import Foundation

extension RenVM {
    struct Script {
        private static let CHECKSUM_LENGTH = 4
        private var bos = Data()
        
        // get current bytes
        var bytes: [UInt8] {
            bos.bytes
        }
        
        mutating func op(_ opcode: OpCode) {
            bos += opcode.rawValue.bytes
        }
        
        mutating func data(_ data: Data) {
            bos += [UInt8(data.count)]
            bos += data
        }
        
        func toAddress(prefix: Data) -> Data {
            let hash = Data(bytes).hash160
            let hashWithPrefix = prefix + hash
            let hashWithChecksum = hashWithPrefix + Self.checksum(hash: hashWithPrefix)
            return hashWithChecksum
        }
        
        static func gatewayScript(gGubKeyHash: Data, gHash: Data) -> Self {
            var script = Script()
            script.data(gHash)
            script.op(.OP_DROP)
            script.op(.OP_DUP)
            script.op(.OP_HASH160)
            script.data(gGubKeyHash)
            script.op(.OP_EQUALVERIFY)
            script.op(.OP_CHECKSIG)
            return script
            
        }
        
        static func createAddressByteArray(gGubKeyHash: Data, gHash: Data, prefix: Data) -> Data {
            gatewayScript(gGubKeyHash: gGubKeyHash, gHash: gHash).toAddress(prefix: prefix)
        }
        
        static func checksum(hash: Data) -> Data {
            let sha256sha256Hash = hash.sha256().sha256()
            return sha256sha256Hash[0..<Self.CHECKSUM_LENGTH]
        }
        
        enum OpCode: UInt8 {
            case OP_DROP = 0x75
            case OP_DUP = 0x76
            case OP_HASH160 = 0xa9
            case OP_EQUALVERIFY = 0x88
            case OP_CHECKSIG = 0xac
        }
    }
}
