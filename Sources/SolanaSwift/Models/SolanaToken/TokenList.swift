//
//  TokenList.swift
//  Alamofire
//
//  Created by Chung Tran on 22/04/2021.
//

import Foundation

extension SolanaSDK {
    struct TokensList: Decodable {
        let name: String
        let logoURI: String
        let keywords: [String]
        let tags: [String: TokenTag]
        let timestamp: String
        var tokens: [Token]
    }
    
    public struct TokenTag: Hashable, Decodable {
        public var name: String
        public var description: String
    }
    
    public enum WrappingToken: String {
        case sollet, wormhole
    }
    
    public struct Token: Hashable, Decodable {
        public init(_tags: [String]?, chainId: Int, address: String, symbol: String, name: String, decimals: SolanaSDK.Decimals, logoURI: String?, tags: [SolanaSDK.TokenTag] = [], extensions: SolanaSDK.TokenExtensions?, isNative: Bool = false) {
            self._tags = _tags
            self.chainId = chainId
            self.address = address
            self.symbol = symbol
            self.name = name
            self.decimals = decimals
            self.logoURI = logoURI
            self.tags = tags
            self.extensions = extensions
            self.isNative = isNative
        }
        
        let _tags: [String]?
        
        public let chainId: Int
        public let address: String
        public let symbol: String
        public let name: String
        public let decimals: Decimals
        public let logoURI: String?
        public var tags: [TokenTag] = []
        public let extensions: TokenExtensions?
        public private(set) var isNative = false
        
        enum CodingKeys: String, CodingKey {
            case chainId, address, symbol, name, decimals, logoURI, extensions, _tags = "tags"
        }
        
        public static func unsupported(
            mint: String?,
            decimals: Decimals = 0,
            symbol: String = ""
        ) -> Token {
            Token(
                _tags: [],
                chainId: 101,
                address: mint ?? "<undefined>",
                symbol: symbol,
                name: mint ?? "<undefined>",
                decimals: decimals,
                logoURI: nil,
                tags: [],
                extensions: nil
            )
        }
        
        public static var nativeSolana: Self {
            .init(
                _tags: [],
                chainId: 101,
                address: "So11111111111111111111111111111111111111112",
                symbol: "SOL",
                name: "Solana",
                decimals: 9,
                logoURI: "https://raw.githubusercontent.com/solana-labs/token-list/main/assets/mainnet/So11111111111111111111111111111111111111112/logo.png",
                tags: [],
                extensions: nil,
                isNative: true
            )
        }
        
        public static var renBTC: Self {
            .init(
                _tags: nil,
                chainId: 101,
                address: PublicKey.renBTCMint.base58EncodedString,
                symbol: "renBTC",
                name: "renBTC",
                decimals: 8,
                logoURI: "https://raw.githubusercontent.com/solana-labs/token-list/main/assets/mainnet/CDJWUqTcYTVAKXAVXoQZFes5JUFc7owSeq7eMQcDSbo5/logo.png",
                extensions: .init(website: "https://renproject.io/", bridgeContract: nil, assetContract: nil, address: nil, explorer: nil, twitter: nil, github: nil, medium: nil, tgann: nil, tggroup: nil, discord: nil, serumV3Usdt: nil, serumV3Usdc: "74Ciu5yRzhe8TFTHvQuEVbFZJrbnCMRoohBK33NNiPtv", coingeckoId: "renbtc", imageUrl: nil, description: nil)
            )
        }
        
        public var wrappedBy: WrappingToken? {
            if tags.contains(where: {$0.name == "wrapped-sollet"}) {
                return .sollet
            }
            
            if tags.contains(where: {$0.name == "wrapped"}) &&
                tags.contains(where: {$0.name == "wormhole"})
            {
                return .wormhole
            }
            
            return nil
        }
        
        public var isLiquidity: Bool {
            tags.contains(where: {$0.name == "lp-token"})
        }
        
        public var isUndefined: Bool {
            symbol.isEmpty
        }
        
        public var isNativeSOL: Bool {
            symbol == "SOL" && isNative
        }
        
        public var isRenBTC: Bool {
            address == PublicKey.renBTCMint.base58EncodedString ||
                address == PublicKey.renBTCMintDevnet.base58EncodedString
        }
    }
    
    public struct TokenExtensions: Hashable, Decodable {
        let website: String?
        let bridgeContract: String?
        let assetContract: String?
        let address: String?
        let explorer: String?
        let twitter: String?
        let github: String?
        let medium: String?
        let tgann: String?
        let tggroup: String?
        let discord: String?
        let serumV3Usdt: String?
        let serumV3Usdc: String?
        let coingeckoId: String?
        let imageUrl: String?
        let description: String?
    }
}
