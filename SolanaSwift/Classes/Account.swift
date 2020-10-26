//
//  Account.swift
//  p2p wallet
//
//  Created by Chung Tran on 10/22/20.
//

import Foundation
import TweetNacl

public extension SolanaSDK {
    struct Account {
        public let phrase: [String]
        public let publicKey: Data
        public let secretKey: Data
        
        public init(phrase: [String] = []) throws {
            let mnemonic: Mnemonic
            if !phrase.isEmpty {
                mnemonic = try Mnemonic(phrase: phrase)
            } else {
                mnemonic = Mnemonic()
            }
            self.phrase = mnemonic.phrase
            
            let seed = mnemonic.seed[0..<32]
            let keys = try NaclSign.KeyPair.keyPair(fromSeed: Data(seed))
            
            self.publicKey = keys.publicKey
            self.secretKey = keys.secretKey
        }
    }
}
