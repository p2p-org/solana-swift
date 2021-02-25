//
//  Message.swift
//  SolanaSwift
//
//  Created by Chung Tran on 11/6/20.
//

import Foundation

public extension SolanaSDK {
    struct Message: Decodable {
        private static let RECENT_BLOCK_HASH_LENGT = 32
        
        public var header = Header()
        public var recentBlockhash: String?
        public var accountKeys = [Account.Meta]()
        public var instructions = [Transaction.Instruction]()
        private(set) var programInstructions: [TransactionInstruction]?
        
        public init() {}
        
        public mutating func add(instruction: TransactionInstruction) {
            accountKeys.appendWritable(contentsOf: instruction.keys)
            accountKeys.appendWritable(Account.Meta(publicKey: instruction.programId, isSigner: false, isWritable: false))
            if programInstructions == nil {
                programInstructions = [TransactionInstruction]()
            }
            programInstructions!.append(instruction)
        }
        
        public mutating func serialize() throws -> [UInt8] {
            guard let string = recentBlockhash
            else {throw Error.invalidRequest(reason: "Blockhash not found")}
            
            guard let programInstructions = programInstructions,
                  programInstructions.count > 0 else {
                throw Error.other("No instructions provided")
            }
            
            let recentBlockhash = Base58.decode(string)
            
            accountKeys = accountKeys.sorted(by: <=)
            var feePayer = accountKeys.removeFirst()
            feePayer.isSigner = true
            feePayer.isWritable = true
            accountKeys.insert(feePayer, at: 0)
            
            let accountKeysSize = accountKeys.count
            let accountAddressesLength = Data.encodeLength(UInt(accountKeysSize))
            
            var compiledInstructionsLength: Int = 0
            var compiledInstructions = [CompiledInstruction]()
            
            for instruction in programInstructions {
                
                let keysSize = instruction.keys.count
                
                var keyIndices = Data()
                for i in 0..<keysSize {
                    keyIndices.append(UInt8(try findAccountIndex(publicKey: instruction.keys[i].publicKey)))
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
            
            var accountKeysBuff = Data(capacity: accountKeysSize * PublicKey.LENGTH)
            
            header = Header()
            
            for meta in accountKeys {
                accountKeysBuff.append(meta.publicKey.data)
                if meta.isSigner {
                    let current = header.numRequiredSignatures ?? 0
                    header.numRequiredSignatures = current + 1
                    if !meta.isWritable {
                        header.numReadonlySignedAccounts += 1
                    }
                } else {
                    if !meta.isWritable {
                        header.numReadonlyUnsignedAccounts += 1
                    }
                }
            }
            
            data.append(contentsOf: header.bytes)
            data.append(contentsOf: accountAddressesLength)
            data.append(accountKeysBuff)
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
        var numRequiredSignatures: UInt8? = 0
        var numReadonlySignedAccounts: UInt8 = 0
        var numReadonlyUnsignedAccounts: UInt8 = 0
        
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

fileprivate extension Array where Element == SolanaSDK.Account.Meta {
    mutating func appendWritable(_ meta: Element) {
        if let existingMeta = first(where: {meta.publicKey == $0.publicKey}) {
            if !existingMeta.isWritable && meta.isWritable {
                append(meta)
            }
        } else {
            append(meta)
        }
    }
    
    mutating func appendWritable(contentsOf array: Self) {
        array.forEach {appendWritable($0)}
    }
}
