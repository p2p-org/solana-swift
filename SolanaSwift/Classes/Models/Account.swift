//
//  Account.swift
//  p2p wallet
//
//  Created by Chung Tran on 10/22/20.
//

import Foundation
import TweetNacl

public extension SolanaSDK {
    struct Account: Codable {
        public let phrase: [String]
        public let publicKey: PublicKey
        public let secretKey: Data
        
        public init(phrase: [String] = []) throws {
            let mnemonic: Mnemonic
            let phrase = phrase.filter {!$0.isEmpty}
            if !phrase.isEmpty {
                mnemonic = try Mnemonic(phrase: phrase)
            } else {
                mnemonic = Mnemonic()
            }
            self.phrase = mnemonic.phrase
            
            let seed = mnemonic.seed[0..<32]
            let keys = try NaclSign.KeyPair.keyPair(fromSeed: Data(seed))
            
            self.publicKey = try PublicKey(data: keys.publicKey)
            self.secretKey = keys.secretKey
        }
        
        public init(secretKey: Data) throws {
            let keys = try NaclSign.KeyPair.keyPair(fromSecretKey: secretKey)
            self.publicKey = try PublicKey(data: keys.publicKey)
            self.secretKey = keys.secretKey
            self.phrase = []
        }
    }
}

public extension SolanaSDK.Account {
    struct Meta: Codable, Comparable {
        public static func < (lhs: SolanaSDK.Account.Meta, rhs: SolanaSDK.Account.Meta) -> Bool {
            if lhs.isSigner != rhs.isSigner {return lhs.isSigner}
            if lhs.isWritable != rhs.isWritable {return lhs.isWritable}
            return false
        }
        
        public let publicKey: SolanaSDK.PublicKey
        public let isSigner: Bool
        public let isWritable: Bool
        
        public init(publicKey: SolanaSDK.PublicKey, isSigner: Bool, isWritable: Bool) {
            self.publicKey = publicKey
            self.isSigner = isSigner
            self.isWritable = isWritable
        }
    
        public init(from decoder: Decoder) throws {
            let value = try decoder.singleValueContainer()
            let string = try value.decode(String.self)
            publicKey = try SolanaSDK.PublicKey(string: string)
            isSigner = false
            isWritable = false
        }
    }
    
    struct Info: Codable {
        public let lamports: UInt64
        public let owner: String
        public let data: AccountData
        public let executable: Bool
        public let rentEpoch: UInt64
        
        public struct AccountData: Codable {
            public let mint: SolanaSDK.PublicKey
            public let owner: SolanaSDK.PublicKey
            public let amount: UInt64
            
            public func encode(to encoder: Encoder) throws {
                fatalError("TODO")
            }
            
            public init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                var data = try container.decode(String.self)
                guard data.count >= 226 else {throw SolanaSDK.Error.other("the length of Account.Info.Data wasn't correct")}
                let mintString = String(data.prefix(32))
                data = String(data.dropFirst(32))
                let ownerString = String(data.prefix(32))
                data = String(data.dropFirst(32))
                let amountString = String(data.prefix(8))
                data = String(data.dropFirst(8))
                mint = try SolanaSDK.PublicKey(data: Data(Base58.bytesFromBase58(mintString)))
                owner = try SolanaSDK.PublicKey(data: Data(Base58.bytesFromBase58(ownerString)))
                let amountBytes = Base58.bytesFromBase58(amountString)
                amount = amountBytes.toUInt64() ?? 0
            }
        }
    }
}
