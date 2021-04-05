//
//  ConfirmedTransactionMessage.swift
//  SolanaSwift
//
//  Created by Chung Tran on 11/6/20.
//

import Foundation

public extension SolanaSDK.ConfirmedTransaction {
    struct Message: Decodable {
        private static let RECENT_BLOCK_HASH_LENGT = 32
        
        public var header = Header()
        public var recentBlockhash: String?
        public var accountKeys = [SolanaSDK.Account.Meta]()
        public var instructions = [SolanaSDK.ConfirmedTransaction.Instruction]()
        private(set) var programInstructions: [SolanaSDK.TransactionInstruction]?
        public var feePayer: SolanaSDK.PublicKey?
        
        public init() {}
        
        public mutating func add(instruction: SolanaSDK.TransactionInstruction) {
            accountKeys.appendWritable(contentsOf: instruction.keys)
            accountKeys.appendWritable(SolanaSDK.Account.Meta(publicKey: instruction.programId, isSigner: false, isWritable: false))
            if programInstructions == nil {
                programInstructions = [SolanaSDK.TransactionInstruction]()
            }
            programInstructions!.append(instruction)
        }
        
        public mutating func serialize() throws -> [UInt8] {
            guard let string = recentBlockhash
            else {throw SolanaSDK.Error.invalidRequest(reason: "Blockhash not found")}
            
            guard let programInstructions = programInstructions,
                  programInstructions.count > 0 else {
                throw SolanaSDK.Error.other("No instructions provided")
            }
            
            guard let feePayer = feePayer else {
                throw SolanaSDK.Error.other("Feepayer not found")
            }
            
            let recentBlockhash = Base58.decode(string)
            
            let accountsModifier: ([SolanaSDK.Account.Meta]) -> [SolanaSDK.Account.Meta] = {accounts in
                var accounts = accounts
                accounts.sort { lhs, rhs in
                    if lhs.isSigner != rhs.isSigner {return lhs.isSigner}
                    if lhs.isWritable != rhs.isWritable {return lhs.isWritable}
                    return false
                }
                return accounts
            }

            accountKeys = accountsModifier(accountKeys)

            
            let feePayerAccount = SolanaSDK.Account.Meta(publicKey: feePayer, isSigner: true, isWritable: true)
            accountKeys.removeAll(where: {$0.publicKey == feePayer})
            accountKeys.insert(feePayerAccount, at: 0)
            let accountKeysSize = accountKeys.count
            let accountAddressesLength = Data.encodeLength(accountKeysSize)
            
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
                    keyIndicesCount: [UInt8](Data.encodeLength(keysSize)),
                    keyIndices: [UInt8](keyIndices),
                    dataLength: [UInt8](Data.encodeLength(instruction.data.count)),
                    data: instruction.data
                )
                
                compiledInstructions.append(compiledInstruction)
                compiledInstructionsLength += compiledInstruction.length
            }
            
            let instructionsLength = Data.encodeLength(compiledInstructions.count).bytes
            
            let bufferSize: Int = Header.LENGTH + Message.RECENT_BLOCK_HASH_LENGT + accountAddressesLength.count + Int(accountKeysSize) * SolanaSDK.PublicKey.LENGTH + instructionsLength.count + compiledInstructionsLength
            
            var data = Data(capacity: bufferSize)
            
            var accountKeysBuff = Data(capacity: accountKeysSize * SolanaSDK.PublicKey.LENGTH)
            
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
        
        private func findAccountIndex(publicKey: SolanaSDK.PublicKey) throws -> Int {
            guard let index = accountKeys.firstIndex(where: {$0.publicKey == publicKey})
            else {throw SolanaSDK.Error.other("Could not found accountIndex")}
            return index
        }
    }
}

extension SolanaSDK.ConfirmedTransaction.Message {
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
