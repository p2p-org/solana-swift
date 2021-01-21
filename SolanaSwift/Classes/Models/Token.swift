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
        
        public init?(layout: AccountLayout, pubkey: String, in network: String) {
            guard let supportedTokens = Self.getSupportedTokens(network: network),
                  let mintAddress = layout.parsed.info?.mint
                  else {
                return nil
            }
            
            
            if let token = supportedTokens.first(where: {$0.mintAddress == mintAddress}) {
                self = token
                self.amount = UInt64(layout.parsed.info?.tokenAmount?.amount ?? "0")
                self.pubkey = pubkey
                self.decimals = layout.parsed.info?.tokenAmount?.decimals
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

