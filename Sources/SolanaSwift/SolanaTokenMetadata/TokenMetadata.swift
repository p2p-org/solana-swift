import Foundation

@available(*, deprecated, renamed: "TokenMetadata")
public typealias Token = TokenMetadata

/// Common token metadata structure.
public struct TokenMetadata: Hashable, Codable {
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

    let _tags: [String]?

    enum CodingKeys: String, CodingKey {
        case chainId, address, symbol, name, decimals, logoURI, extensions, _tags = "tags", supply
    }

    public init(
        _tags: [String]?,
        chainId: Int,
        address: String,
        symbol: String,
        name: String,
        decimals: UInt8,
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

    public static func unsupported(
        mint: String,
        decimals: Decimals,
        symbol: String,
        supply: UInt64?
    ) -> TokenMetadata {
        TokenMetadata(
            _tags: [],
            chainId: 101,
            address: mint,
            symbol: symbol,
            name: mint,
            decimals: decimals,
            logoURI: nil,
            tags: [],
            extensions: nil,
            supply: supply
        )
    }

    public var isNativeSOL: Bool {
        symbol == "SOL" && isNative
    }
}

public struct TokenTag: Hashable, Codable {
    public var name: String
    public var description: String
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
