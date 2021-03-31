//
//  Token.swift
//  SolanaSwift
//
//  Created by Chung Tran on 13/11/2020.
//

import Foundation

public extension SolanaSDK {
    struct Token: Decodable, Hashable {
        public let mintAddress: String
        public var pubkey: String?
        public let symbol: String
        public let icon: String?
        public var lamports: UInt64?
        public var decimals: Int?
        let liquidity: Bool?
        public var wrappedBy: String?
        
        public var isLiquidity: Bool {
            liquidity == true
        }
        
        public init(
            name: String,
            mintAddress: String,
            pubkey: String?,
            symbol: String,
            icon: String?,
            lamports: UInt64?,
            decimals: Int?,
            isLiquidity: Bool? = nil,
            wrappedBy: String?
        ) {
            self.mintAddress = mintAddress
            self.pubkey = pubkey
            self.symbol = symbol
            self.icon = icon
            self.lamports = lamports
            self.decimals = decimals
            self.liquidity = isLiquidity
            self.wrappedBy = wrappedBy
        }
        
        public init(accountInfo: AccountInfo, pubkey: String, in network: Network) {
            let supportedTokens = Self.getSupportedTokens(network: network)
            
            if let token = supportedTokens?.first(where: {$0.mintAddress == accountInfo.mint.base58EncodedString}) {
                self = token
                self.lamports = accountInfo.lamports
                self.pubkey = pubkey
                self.decimals = nil
            } else {
                self = Token(name: accountInfo.mint.base58EncodedString, mintAddress: accountInfo.mint.base58EncodedString, pubkey: pubkey, symbol: "", icon: nil, lamports: accountInfo.lamports, decimals: nil, isLiquidity: true, wrappedBy: nil)
            }
        }
        
        public static func getSupportedTokens(network: Network) -> [Self]? {
            guard let string = SupportedTokens.shared[network],
                  let data = string.data(using: .utf8)
            else {
                return nil
            }
            do {
                let tokens = try JSONDecoder().decode([SolanaSDK.Token].self, from: data)
                return tokens
            } catch {
                print(error)
                return nil
            }
        }
    }
}

