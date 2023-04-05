import Foundation

struct TokensList: Codable {
    let name: String
    let logoURI: String
    let keywords: [String]
    let tags: [String: TokenTag]
    let timestamp: String
    var tokens: [Token]
}

public struct TokenTag: Hashable, Codable {
    public var name: String
    public var description: String
}

public enum WrappingToken: String {
    case sollet, wormhole
}

public struct Token: Hashable, Codable {
    public init(
        _tags: [String]?,
        chainId: Int,
        address: String,
        symbol: String,
        name: String,
        decimals: Decimals,
        logoURI: String?,
        tags: [TokenTag] = [],
        extensions: TokenExtensions?,
        isNative: Bool = false,
        supply: UInt64? = nil
    ) {
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
        self.supply = supply
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
    public let supply: UInt64?
    public private(set) var isNative = false

    enum CodingKeys: String, CodingKey {
        case chainId, address, symbol, name, decimals, logoURI, extensions, _tags = "tags", supply
    }

    public static func unsupported(
        mint: String?,
        decimals: Decimals = 0,
        symbol: String = "",
        supply: UInt64? = nil
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
            extensions: nil,
            supply: supply
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
            logoURI: "https://raw.githubusercontent.com/p2p-org/solana-token-list/main/assets/mainnet/So11111111111111111111111111111111111111112/logo.png",
            tags: [],
            extensions: TokenExtensions(coingeckoId: "solana"),
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
            logoURI: "https://raw.githubusercontent.com/p2p-org/solana-token-list/main/assets/mainnet/CDJWUqTcYTVAKXAVXoQZFes5JUFc7owSeq7eMQcDSbo5/logo.png",
            extensions: .init(
                website: "https://renproject.io/",
                serumV3Usdc: "74Ciu5yRzhe8TFTHvQuEVbFZJrbnCMRoohBK33NNiPtv",
                coingeckoId: "renbtc"
            )
        )
    }
    
    public static var usdc: Self {
        .init(
            _tags: nil,
            chainId: 101,
            address: PublicKey.usdcMint.base58EncodedString,
            symbol: "USDC",
            name: "USDC",
            decimals: 6,
            logoURI: "https://raw.githubusercontent.com/p2p-org/solana-token-list/main/assets/mainnet/EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v/logo.png",
            extensions: .init(coingeckoId: "usd-coin")
        )
    }

    public static var usdt: Self {
        .init(
            _tags: nil,
            chainId: 101,
            address: PublicKey.usdtMint.base58EncodedString,
            symbol: "USDT",
            name: "USDT",
            decimals: 6,
            logoURI: "https://raw.githubusercontent.com/p2p-org/solana-token-list/main/assets/mainnet/Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB/logo.png",
            extensions: .init(coingeckoId: "tether")
        )
    }

    public static var eth: Self {
        .init(
            _tags: nil,
            chainId: 101,
            address: "7vfCXTUXx5WJV5JADk17DUJ4ksgau7utNKj4b963voxs",
            symbol: "ETH",
            name: "Ether (Portal)",
            decimals: 8,
            logoURI: "https://raw.githubusercontent.com/p2p-org/solana-token-list/main/assets/mainnet/7vfCXTUXx5WJV5JADk17DUJ4ksgau7utNKj4b963voxs/logo.png",
            extensions: .init(coingeckoId: "ethereum")
        )
    }

    public static var usdcet: Self {
        .init(
            _tags: nil,
            chainId: 101,
            address: "A9mUU4qviSctJVPJdBJWkb28deg915LYJKrzQ19ji3FM",
            symbol: "USDCet",
            name: "USD Coin (Wormhole)",
            decimals: 6,
            logoURI: "https://raw.githubusercontent.com/solana-labs/token-list/main/assets/mainnet/A9mUU4qviSctJVPJdBJWkb28deg915LYJKrzQ19ji3FM/logo.png",
            extensions: .init(coingeckoId: "usd-coin")
        )
    }

    public var wrappedBy: WrappingToken? {
        if tags.contains(where: { $0.name == "wrapped-sollet" }) {
            return .sollet
        }

        if tags.contains(where: { $0.name == "wrapped" }),
           tags.contains(where: { $0.name == "wormhole" })
        {
            return .wormhole
        }

        return nil
    }

    public var isLiquidity: Bool {
        tags.contains(where: { $0.name == "lp-token" })
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

public struct TokenExtensions: Hashable, Codable {
    public let website: String?
    public let bridgeContract: String?
    public let assetContract: String?
    public let address: String?
    public let explorer: String?
    public let twitter: String?
    public let github: String?
    public let medium: String?
    public let tgann: String?
    public let tggroup: String?
    public let discord: String?
    public let serumV3Usdt: String?
    public let serumV3Usdc: String?
    public let coingeckoId: String?
    public let imageUrl: String?
    public let description: String?

    public init(
        website: String? = nil,
        bridgeContract: String? = nil,
        assetContract: String? = nil,
        address: String? = nil,
        explorer: String? = nil,
        twitter: String? = nil,
        github: String? = nil,
        medium: String? = nil,
        tgann: String? = nil,
        tggroup: String? = nil,
        discord: String? = nil,
        serumV3Usdt: String? = nil,
        serumV3Usdc: String? = nil,
        coingeckoId: String?,
        imageUrl: String? = nil,
        description: String? = nil
    ) {
        self.website = website
        self.bridgeContract = bridgeContract
        self.assetContract = assetContract
        self.address = address
        self.explorer = explorer
        self.twitter = twitter
        self.github = github
        self.medium = medium
        self.tgann = tgann
        self.tggroup = tggroup
        self.discord = discord
        self.serumV3Usdt = serumV3Usdt
        self.serumV3Usdc = serumV3Usdc
        self.coingeckoId = coingeckoId
        self.imageUrl = imageUrl
        self.description = description
    }
}
