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
        public var pubkey: String?
        public let symbol: String
        public let icon: String?
        public var amount: UInt64?
        public var decimals: Int?
        
        public init?(accountInfo: AccountInfo, pubkey: String, in network: Network) {
            guard let supportedTokens = Self.getSupportedTokens(network: network)
            else {
                return nil
            }
            
            
            if let token = supportedTokens.first(where: {$0.mintAddress == accountInfo.mint.base58EncodedString}) {
                self = token
                self.amount = accountInfo.amount
                self.pubkey = pubkey
                self.decimals = nil
                return
            }
            
            print("unsupported token: \(accountInfo.mint.base58EncodedString)")
            return nil
        }
        
        public static func getSupportedTokens(network: Network) -> [Self]? {
            guard let string = SupportedTokens.shared[network],
                  let data = string.data(using: .utf8)
            else {
                return nil
            }
            return try? JSONDecoder().decode([SolanaSDK.Token].self, from: data)
        }
    }
}

