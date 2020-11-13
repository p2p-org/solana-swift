//
//  Token.swift
//  SolanaSwift
//
//  Created by Chung Tran on 13/11/2020.
//

import Foundation

public extension SolanaSDK {
    struct Token: Decodable {
        public let name: String
        public let mintAddress: String
        public let symbol: String
        public let icon: String?
        
        public init(accountInfo: Account.Info, inCluster cluster: String) throws {
            guard let mintAddress = accountInfo.data.mint?.base58EncodedString else {
                throw Error.other("Mint address not found")
            }
            
            let supportedTokens = try Self.getSupportedTokens(cluster: cluster)
            
            if let token = supportedTokens.first(where: {$0.mintAddress == mintAddress}) {
                self = token
                return
            }
            
            throw Error.other("Unsupported token")
        }
        
        public static func getSupportedTokens(cluster: String) throws -> [Self] {
            guard let string = SupportedTokens.shared[cluster],
                  let data = string.data(using: .utf8)
            else {
                throw Error.other("Data wasn't valid")
            }
            return try JSONDecoder().decode([SolanaSDK.Token].self, from: data)
        }
    }
}

