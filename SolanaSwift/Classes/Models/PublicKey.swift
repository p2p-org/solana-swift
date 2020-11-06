//
//  PublicKey.swift
//  SolanaSwift
//
//  Created by Chung Tran on 11/6/20.
//

import Foundation
import Base58Swift

public extension SolanaSDK {
    struct PublicKey: Codable, Equatable {
        public static let LENGTH = 32
        public let bytes: [Byte]
        
        public init(string: String) throws {
            guard string.utf8.count >= SolanaSDK.PublicKey.LENGTH,
               let bytes = Base58.base58Decode(string)
            else {
                throw Error.other("Invalid public key input")
            }
            self.bytes = bytes
        }
        
        public init(data: Data) throws {
            guard data.count <= SolanaSDK.PublicKey.LENGTH else {
                throw Error.other("Invalid public key input")
            }
            self.bytes = [Byte](data)
        }
        
        public var base58EncodedString: String {
            Base58.base58Encode(bytes)
        }
        
        public var data: Data {
            Data(bytes: bytes)
        }
    }
}
