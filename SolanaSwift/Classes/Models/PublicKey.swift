//
//  PublicKey.swift
//  SolanaSwift
//
//  Created by Chung Tran on 11/6/20.
//

import Foundation

public extension SolanaSDK {
    struct PublicKey: Codable, Equatable, CustomStringConvertible, Hashable {
        public static let LENGTH = 32
        public let bytes: [UInt8]
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(base58EncodedString)
        }
        
        public init(from decoder: Decoder) throws {
            var container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            try self.init(string: string)
        }
        
        public init(string: String) throws {
            guard string.utf8.count >= SolanaSDK.PublicKey.LENGTH
            else {
                throw Error.other("Invalid public key input")
            }
            let bytes = Base58.decode(string)
            self.bytes = bytes
        }
        
        public init(data: Data) throws {
            guard data.count <= SolanaSDK.PublicKey.LENGTH else {
                throw Error.other("Invalid public key input")
            }
            self.bytes = [UInt8](data)
        }
        
        public init(bytes: [UInt8]?) throws {
            guard let bytes = bytes, bytes.count <= PublicKey.LENGTH else {
                throw Error.other("Invalid public key input")
            }
            self.bytes = bytes
        }
        
        public var base58EncodedString: String {
            Base58.encode(bytes)
        }
        
        public var data: Data {
            Data(bytes)
        }
        
        public var description: String {
            base58EncodedString
        }
    }
}
