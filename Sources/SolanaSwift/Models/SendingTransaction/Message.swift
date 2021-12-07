//
//  Message2.swift
//  SolanaSwift
//
//  Created by Chung Tran on 02/04/2021.
//

import Foundation

/// Blockhash as Base58 string.
typealias BlockHash = String

extension SolanaSDK.Transaction {
    public struct Message {
        // MARK: - Constants
        private static let RECENT_BLOCK_HASH_LENGTH = 32
        
        // MARK: - Properties
        var header: Header
        var accountKeys: [SolanaSDK.PublicKey]
        var recentBlockhash: BlockHash
        var instructions: [CompiledInstruction]
        
        init(header: Header, accountKeys: [SolanaSDK.PublicKey], recentBlockhash: BlockHash, instructions: [CompiledInstruction]) {
            self.header = header
            self.accountKeys = accountKeys
            self.recentBlockhash = recentBlockhash
            self.instructions = instructions
        }
        
        func serialize() throws -> Data {
            // Header
            let header = encodeHeader()
            
            // Account keys
            let accountKeys = encodeAccountKeys()
            
            // RecentBlockHash
            let recentBlockhash = encodeRecentBlockhash()
            
            // Compiled instruction
            let compiledInstruction = try encodeInstructions()
            
            // Construct data
//            let bufferSize: Int =
//                Header.LENGTH // header
//                + keyCount.count // number of account keys
//                + Int(accountKeys.count) * PublicKey.LENGTH // account keys
//                + RECENT_BLOCK_HASH_LENGTH // recent block hash
//                + instructionsLength.count
//                + compiledInstructionsLength
            
            var data = Data(/*capacity: bufferSize*/)
            
            // Append data
            data.append(header)
            data.append(accountKeys)
            data.append(recentBlockhash)
            data.append(compiledInstruction)
            
            return data
        }
        
        static func from(data: Data) throws -> Message {
            var data = data
            
            let numRequiredSignatures = data.popFirst()!
            let numReadonlySignedAccounts = data.popFirst()!
            let numReadonlyUnsignedAccounts = data.popFirst()!
            
            let accountCount = try data.decodeLength()
            var accountKeys: [SolanaSDK.PublicKey] = []
            for index in stride(from: 0, through: accountCount - 1, by: 1) {
                let account = data.prefix(SolanaSDK.PublicKey.numberOfBytes)
                data = data.dropFirst(SolanaSDK.PublicKey.numberOfBytes)
                accountKeys.append(try SolanaSDK.PublicKey.init(string: Base58.encode(account.bytes)))
            }
            
            let recentBlockhash = data.prefix(SolanaSDK.PublicKey.numberOfBytes)
            print(Base58.encode(recentBlockhash.bytes))
            data = data.dropFirst(SolanaSDK.PublicKey.numberOfBytes)
            
            let instructionCount = try data.decodeLength()
            print(instructionCount)
            var instructions: [CompiledInstruction] = []
            for index in stride(from: 0, through: instructionCount - 1, by: 1) {
                let programIdIndex = data.popFirst()!
                let accountCount = try data.decodeLength()
                let accounts = data.prefix(accountCount)
                data = data.dropFirst(accountCount)
                let dataLength = try data.decodeLength()
                let dataSlice = data.prefix(dataLength)
                data = data.suffix(dataLength)
                instructions.append(
                    CompiledInstruction(
                        programIdIndex: programIdIndex,
                        keyIndicesCount: Data.encodeLength(accountCount).bytes,
                        keyIndices: accounts.bytes,
                        dataLength: Data.encodeLength(dataLength).bytes,
                        data: dataSlice.bytes
                    )
                )
            }
            
            return Message(
                header: Header(numRequiredSignatures: Int(numRequiredSignatures),
                    numReadonlySignedAccounts: Int(numReadonlySignedAccounts),
                    numReadonlyUnsignedAccounts: Int(numReadonlyUnsignedAccounts)
                ),
                accountKeys: accountKeys,
                recentBlockhash: Base58.encode(recentBlockhash.bytes),
                instructions: instructions
            )
        }
        
        func isAccountWritable(index: Int) -> Bool {
            (index < header.numRequiredSignatures - header.numReadonlySignedAccounts)
                || (index >= header.numRequiredSignatures && index < accountKeys.count - header.numReadonlyUnsignedAccounts)
        }
        
        func isAccountSigner(index: Int) -> Bool {
            index < header.numRequiredSignatures
        }
        
        private func encodeHeader() -> Data {
            Data(header.bytes)
        }
        
        private func encodeAccountKeys() -> Data {
            // length
            let keyCount = encodeLength(accountKeys.count)
            
            // construct data
            var data = Data(capacity: keyCount.count + accountKeys.count * SolanaSDK.PublicKey.numberOfBytes)
            
            // append data
            data.append(keyCount)
            for key in accountKeys {
                data.append(key.data)
            }
            return data
        }
        
        private func encodeRecentBlockhash() -> Data {
            Data(Base58.decode(recentBlockhash))
        }
        
        private func encodeInstructions() throws -> Data {
            let instructionsLength = Data.encodeLength(instructions.count)
            return instructionsLength + instructions.reduce(Data(), { $0 + $1.serializedData })
        }
        
        private func encodeLength(_ length: Int) -> Data {
            Data.encodeLength(length)
        }
    }
}

extension SolanaSDK.Transaction.Message {
    // MARK: - Nested type
    public struct Header: Decodable {
        static let LENGTH = 3
        
        var numRequiredSignatures: Int = 0
        var numReadonlySignedAccounts: Int = 0
        var numReadonlyUnsignedAccounts: Int = 0
        
        var bytes: [UInt8] {
            [UInt8(numRequiredSignatures), UInt8(numReadonlySignedAccounts), UInt8(numReadonlyUnsignedAccounts)]
        }
    }
    
    // TODO: follow code from solana!
    public struct CompiledInstruction {
        let programIdIndex: UInt8
        let keyIndicesCount: [UInt8]
        let keyIndices: [UInt8]
        let dataLength: [UInt8]
        let data: [UInt8]
        
        var accounts: [Int] {
            get {
                keyIndices.map { x in Int(x) }
            }
        }
        var programIdIndexValue: Int {
            get {
                Int(programIdIndex)
            }
        }
        
        var serializedData: Data {
            Data([programIdIndex]
                + keyIndicesCount
                + keyIndices
                + dataLength
                + data)
        }
    }
}

extension Sequence where Iterator.Element == SolanaSDK.TransactionInstruction {
    func compile(accountKeys: [SolanaSDK.PublicKey]) -> [SolanaSDK.Transaction.Message.CompiledInstruction] {
        var compiledInstructions = [SolanaSDK.Transaction.Message.CompiledInstruction]()
        
        for instruction in self {
            
            let keysSize = instruction.keys.count
            
            var keyIndices = Data()
            for i in 0..<keysSize {
                let index = try accountKeys.index(of: instruction.keys[i].publicKey)!
                keyIndices.append(UInt8(index))
            }
            
            let compiledInstruction = SolanaSDK.Transaction.Message.CompiledInstruction(
                programIdIndex: UInt8(try accountKeys.index(of: instruction.programId)!),
                keyIndicesCount: [UInt8](Data.encodeLength(keysSize)),
                keyIndices: [UInt8](keyIndices),
                dataLength: [UInt8](Data.encodeLength(instruction.data.count)),
                data: instruction.data
            )
            
            compiledInstructions.append(compiledInstruction)
        }
        
        return compiledInstructions
    }
}
