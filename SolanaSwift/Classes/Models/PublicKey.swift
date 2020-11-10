//
//  PublicKey.swift
//  SolanaSwift
//
//  Created by Chung Tran on 11/6/20.
//

import Foundation

public extension SolanaSDK {
    struct PublicKey: Codable, Equatable {
        public static let LENGTH = 32
        public let bytes: [UInt8]
        
        public init(string: String) throws {
            guard string.utf8.count >= SolanaSDK.PublicKey.LENGTH
            else {
                throw Error.other("Invalid public key input")
            }
            let bytes = Base58.bytesFromBase58(string)
            self.bytes = bytes
        }
        
        public init(data: Data) throws {
            guard data.count <= SolanaSDK.PublicKey.LENGTH else {
                throw Error.other("Invalid public key input")
            }
            self.bytes = [UInt8](data)
        }
        
        public var base58EncodedString: String {
            Base58.base58FromBytes(bytes)
        }
        
        public var string: String {
            base58EncodedString
        }
        
        public var data: Data {
            Data(bytes: bytes)
        }
    }
}
