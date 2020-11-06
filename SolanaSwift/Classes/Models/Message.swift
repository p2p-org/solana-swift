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
        
        public init() {}
        
        public mutating func add(instruction: Transaction.Instruction) {
            if instructions == nil {
                instructions = [Transaction.Instruction]()
            }
            accountKeys.append(contentsOf: instruction.keys)
            accountKeys.append(Account.Meta(publicKey: instruction.programId, isSigner: false, isWritable: false))
            instructions!.append(instruction)
        }
        
        public func serialize() throws -> [UInt8] {
            guard let string = recentBlockhash, let recentBlockhash = Base58.base58Decode(string)
            else {throw Error.other("Could not decode recentBlockhash")}
            
            guard let instructions = instructions else {
                throw Error.other("Instructions not found")
            }
            
            let accountKeysSize = accountKeys.count
            let accountAddressesLength = Data.encodeLength(UInt(accountKeysSize))
            
            var compiledInstructionsLength: Int = 0
            var compiledInstructions = [CompiledInstruction]()
            
            for instruction in instructions {
                let keysSize = instruction.keys.count
                
                var keyIndices = Data(capacity: Int(keysSize))
                for _ in 0..<keysSize {
                    keyIndices.append(UInt8(try findAccountIndex(publicKey: instruction.programId)))
                }
                
                let compiledInstruction = CompiledInstruction(
                    programIdIndex: UInt8(try findAccountIndex(publicKey: instruction.programId)),
                    keyIndicesCount: [UInt8](Data.encodeLength(UInt(keysSize))),
                    keyIndices: [UInt8](keyIndices),
                    dataLength: [UInt8](Data.encodeLength(UInt(instruction.data.count))),
                    data: instruction.data
                )
                
                compiledInstructions.append(compiledInstruction)
                compiledInstructionsLength += compiledInstruction.length
            }
            
            let instructionsLength = Data.encodeLength(UInt(compiledInstructions.count)).bytes
            
            let bufferSize: Int = Message.Header.LENGTH + Message.RECENT_BLOCK_HASH_LENGT + accountAddressesLength.count + Int(accountKeysSize) * PublicKey.LENGTH + instructionsLength.count + compiledInstructionsLength
            
            var data = Data(capacity: bufferSize)
            data.append(contentsOf: header.bytes)
            data.append(contentsOf: accountAddressesLength)
            data.append(contentsOf: accountKeys.reduce([]) {$0 + $1.publicKey.bytes})
            data.append(contentsOf: recentBlockhash)
            data.append(contentsOf: instructionsLength)
            data.append(contentsOf: compiledInstructions.reduce([], { (result, instruction) -> [UInt8] in
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
    public struct Header: Decodable {
        static let LENGTH = 3
        // TODO:
        var numRequiredSignatures: UInt8? = 1
        var numReadonlySignedAccounts: UInt8 = 0
        var numReadonlyUnsignedAccounts: UInt8 = 1
        
        var bytes: [UInt8] {
            [numRequiredSignatures ?? 1, numReadonlySignedAccounts, numReadonlyUnsignedAccounts]
        }
    }
    
    struct CompiledInstruction {
        let programIdIndex: UInt8
        let keyIndicesCount: [UInt8]
        let keyIndices: [UInt8]
        let dataLength: [UInt8]
        let data: [UInt8]
        
        var length: Int {
            1 + keyIndicesCount.count + keyIndices.count + dataLength.count + data.count
        }
    }
}
