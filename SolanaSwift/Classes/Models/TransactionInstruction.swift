//
//  TransactionInstruction.swift
//  SolanaSwift
//
//  Created by Chung Tran on 19/01/2021.
//

import Foundation

extension SolanaSDK {
    public struct TransactionInstruction: Decodable {
        public let keys: [SolanaSDK.Account.Meta]
        public let programId: SolanaSDK.PublicKey
        public let data: [UInt8]
    }
}

extension RawRepresentable where RawValue == UInt32 {
    var indexBytes: [UInt8] {rawValue.bytes}
    func encode(_ array: [InstructionEncodable]) -> Data {
        var data = Data()
        data.append(contentsOf: indexBytes)
        for el in array {
            data.append(contentsOf: el.instructionEncode())
        }
        return data
    }
}

protocol InstructionEncodable {
    func instructionEncode() -> [UInt8]
}

extension UInt8: InstructionEncodable {
    func instructionEncode() -> [UInt8] {
        [self]
    }
}

extension Array: InstructionEncodable where Element == UInt8 {
    func instructionEncode() -> [UInt8] {
        self
    }
}

extension UInt64: InstructionEncodable {
    func instructionEncode() -> [UInt8] {
        withUnsafeBytes(of: littleEndian, Array.init)
    }
}

extension SolanaSDK.PublicKey: InstructionEncodable {
    func instructionEncode() -> [UInt8] {
        bytes
    }
}

extension Data: InstructionEncodable {
    func instructionEncode() -> [UInt8] {
        bytes
    }
}
