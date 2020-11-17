//
//  Token.swift
//  SolanaSwift
//
//  Created by Chung Tran on 13/11/2020.
//

import Foundation

public extension SolanaSDK {
    struct Token: Decodable, Hashable {
        public let name: String
        public let mintAddress: String
        public var owner: String?
        public let symbol: String
        public let icon: String?
        public var amount: UInt64?
        
        public init?(accountInfo: Account.Info, in network: String) {
            guard let mintAddress = accountInfo.data.mint?.base58EncodedString else {
                return nil
            }
            
            guard let supportedTokens = Self.getSupportedTokens(network: network) else {
                return nil
            }
            
            if let token = supportedTokens.first(where: {$0.mintAddress == mintAddress}) {
                self = token
                self.amount = accountInfo.data.amount
                self.owner = accountInfo.data.owner?.base58EncodedString
                return
            }
            
            print("unsupported token: \(mintAddress)")
            return nil
        }
        
        public static func getSupportedTokens(network: String) -> [Self]? {
            guard let string = SupportedTokens.shared[network],
                  let data = string.data(using: .utf8)
            else {
                return nil
            }
            return try? JSONDecoder().decode([SolanaSDK.Token].self, from: data)
        }
    }
}

