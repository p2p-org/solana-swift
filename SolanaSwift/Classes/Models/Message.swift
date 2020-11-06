//
//  Message.swift
//  SolanaSwift
//
//  Created by Chung Tran on 11/6/20.
//

import Foundation
import Base58Swift

public extension SolanaSDK {
    struct Message: Decodable {
        private static let RECENT_BLOCK_HASH_LENGT = 32
        
        public var header = Header()
        public var recentBlockhash: String?
        public var accountKeys = [Account.Meta]()
        private(set) var instructions: [Transaction.Instruction]?
        
        mutating func add(instruction: Transaction.Instruction) {
            if instructions == nil {
                instructions = [Transaction.Instruction]()
            }
            accountKeys.append(contentsOf: instruction.keys)
            accountKeys.append(Account.Meta(publicKey: instruction.programId, isSigner: false, isWritable: false))
            instructions!.append(instruction)
        }
        
        func serialize() throws -> [Byte] {
            guard let string = recentBlockhash, let recentBlockhash = Base58.base58Decode(string)
            else {throw Error.other("Could not decode recentBlockhash")}
            
            guard let instructions = instructions else {
                throw Error.other("Instructions not found")
            }
            
            let accountKeysSize = accountKeys.size
            let accountAddressesLength = Data.encodeLength(accountKeysSize)
            
            var compiledInstructionsLength: Int = 0
            var compiledInstructions = [CompiledInstruction]()
            
            for instruction in instructions {
                let keysSize = instruction.keys.size
                
                var keyIndices = Data(capacity: Int(keysSize))
                for i in 0..<keysSize {
                    keyIndices[Data.Index(i)] = Byte(try findAccountIndex(publicKey: instruction.programId))
                }
                
                let compiledInstruction = CompiledInstruction(
                    programIdIndex: Byte(try findAccountIndex(publicKey: instruction.programId)),
                    keyIndicesCount: [Byte](Data.encodeLength(keysSize)),
                    keyIndices: [Byte](keyIndices),
                    dataLength: [Byte](Data.encodeLength(UInt(instruction.data.count))),
                    data: instruction.data
                )
                
                compiledInstructions.append(compiledInstruction)
                compiledInstructionsLength += compiledInstruction.length
            }
            
            let instructionsLength = Data.encodeLength(compiledInstructions.size).bytes
            
            let bufferSize: Int = Message.Header.LENGTH + Message.RECENT_BLOCK_HASH_LENGT + accountAddressesLength.count + Int(accountKeysSize) * PublicKey.LENGTH + instructionsLength.count + compiledInstructionsLength
            
            var data = Data(capacity: bufferSize)
            data.append(contentsOf: header.bytes)
            data.append(contentsOf: accountAddressesLength)
            data.append(contentsOf: accountKeys.reduce([]) {$0 + $1.publicKey.bytes})
            data.append(contentsOf: recentBlockhash)
            data.append(contentsOf: instructionsLength)
            data.append(contentsOf: compiledInstructions.reduce([], { (result, instruction) -> [Byte] in
                var bytes = result
                bytes.append(instruction.programIdIndex)
                bytes += instruction.keyIndicesCount
                bytes += instruction.keyIndices
                bytes += instruction.dataLength
                bytes += instruction.data
                return bytes
            }))
            return data.bytes
        }
        
        private func findAccountIndex(publicKey: PublicKey) throws -> Int {
            guard let index = accountKeys.firstIndex(where: {$0.publicKey == publicKey})
            else {throw Error.other("Could not found accountIndex")}
            return index
        }
    }
}

extension SolanaSDK.Message {
    typealias Byte = UInt8
    public struct Header: Decodable {
        static let LENGTH = 3
        // TODO:
        var numRequiredSignatures: Byte? = 1
        var numReadonlySignedAccounts: Byte = 0
        var numReadonlyUnsignedAccounts: Byte = 1
        
        var bytes: [Byte] {
            [numRequiredSignatures ?? 1, numReadonlySignedAccounts, numReadonlyUnsignedAccounts]
        }
    }
    
    struct CompiledInstruction {
        let programIdIndex: Byte
        let keyIndicesCount: [Byte]
        let keyIndices: [Byte]
        let dataLength: [Byte]
        let data: [Byte]
        
        var length: Int {
            1 + keyIndicesCount.count + keyIndices.count + dataLength.count + data.count
        }
    }
}
