//
//  Account.swift
//  p2p wallet
//
//  Created by Chung Tran on 10/22/20.
//

import Foundation
import TweetNacl
import CryptoSwift

public extension SolanaSDK {
    struct Account: Codable {
        public let phrase: [String]
        public let publicKey: PublicKey
        public let secretKey: Data
        
        public init(phrase: [String] = [], network: Network) throws {
            let mnemonic: Mnemonic
            var phrase = phrase.filter {!$0.isEmpty}
            if !phrase.isEmpty {
                mnemonic = try Mnemonic(phrase: phrase)
            } else {
                mnemonic = Mnemonic()
                phrase = mnemonic.phrase
            }
            self.phrase = phrase
            
            let keychain = try Keychain(seedString: phrase.joined(separator: " "), network: network.cluster)
            
            guard let seed = try keychain.derivedKeychain(at: "m/501'/0'/0/0").privateKey else {
                throw Error.other("Could not derivate private key")
            }
            
            let keys = try NaclSign.KeyPair.keyPair(fromSeed: seed)
            
            self.publicKey = try PublicKey(data: keys.publicKey)
            self.secretKey = keys.secretKey
        }
        
        public init(secretKey: Data) throws {
            let keys = try NaclSign.KeyPair.keyPair(fromSecretKey: secretKey)
            self.publicKey = try PublicKey(data: keys.publicKey)
            self.secretKey = keys.secretKey
            let phrase = try Mnemonic.toMnemonic(secretKey.bytes)
            self.phrase = phrase
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
}
