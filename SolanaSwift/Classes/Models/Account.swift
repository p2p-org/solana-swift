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
    }
}

public extension SolanaSDK.Account {
    struct Meta: Codable {
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
