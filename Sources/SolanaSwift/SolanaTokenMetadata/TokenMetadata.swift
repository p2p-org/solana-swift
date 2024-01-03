import Foundation

// MARK: - Deprecation

@available(*, deprecated, renamed: "TokenMetadata")
public typealias Token = TokenMetadata

public extension TokenMetadata {
    @available(*, deprecated, renamed: "mintAddress")
    var address: String {
        mintAddress
    }
}

// MARK: - TokenMetadata

/// Common token metadata structure.
public struct TokenMetadata: Hashable, Codable, Equatable {
    public let chainId: Int
    public let mintAddress: String
    public let symbol: String
    public let name: String
    public let decimals: Decimals
    public let logoURI: String?
    public var tags: [TokenTag]
    public let extensions: [String: TokenExtensionValue]?
    public let supply: UInt64?
    public private(set) var isNative = false

    let _tags: [String]?

    enum CodingKeys: String, CodingKey {
        case chainId, mintAddress = "address", symbol, name, decimals, logoURI, extensions, _tags = "tags", supply
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        chainId = try container.decode(Int.self, forKey: .chainId)
        mintAddress = try container.decode(String.self, forKey: .mintAddress)
        symbol = try container.decode(String.self, forKey: .symbol)
        name = try container.decode(String.self, forKey: .name)
        decimals = try container.decode(Decimals.self, forKey: .decimals)
        logoURI = try container.decodeIfPresent(String.self, forKey: .logoURI)
        extensions = try container.decodeIfPresent([String: TokenExtensionValue].self, forKey: .extensions)
        _tags = try container.decodeIfPresent([String].self, forKey: ._tags)
        supply = try container.decodeIfPresent(UInt64.self, forKey: .supply)

        // Customizing tags
        tags = _tags?.map { tag in TokenTag(name: tag, description: tag) } ?? []
    }

    public init(
        tags: [String]?,
        chainId: Int,
        mintAddress: String,
        symbol: String,
        name: String,
        decimals: UInt8,
        logoURI: String?,
        extensions: [String: TokenExtensionValue]?,
        isNative: Bool = false,
        supply: UInt64? = nil
    ) {
        _tags = tags
        self.chainId = chainId
        self.mintAddress = mintAddress
        self.symbol = symbol
        self.name = name
        self.decimals = decimals
        self.logoURI = logoURI
        self.tags = tags?.map { tag in TokenTag(name: tag, description: tag) } ?? []
        self.extensions = extensions
        self.isNative = isNative
        self.supply = supply
    }

    public static func unsupported(
        tags: [String]?,
        mint: String,
        decimals: Decimals,
        symbol: String,
        supply: UInt64?
    ) -> TokenMetadata {
        TokenMetadata(
            tags: tags,
            chainId: 101,
            mintAddress: mint,
            symbol: symbol,
            name: mint,
            decimals: decimals,
            logoURI: nil,
            extensions: nil,
            supply: supply
        )
    }

    @available(*, deprecated, renamed: "isNative")
    public var isNativeSOL: Bool {
        isNative
    }

    public func hasSameMintAddress(with other: TokenMetadata) -> Bool {
        mintAddress == other.mintAddress
    }

    public var generalTokenExtensions: GeneralTokenExtension {
        GeneralTokenExtension(data: extensions ?? [:])
    }
}

public struct TokenTag: Hashable, Codable {
    public var name: String
    public var description: String
}

public enum TokenExtensionValue: Hashable, Codable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case unknown

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else if let value = try? container.decode(Double.self) {
            self = .double(value)
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else {
            self = .unknown
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case let .string(value):
            try container.encode(value)
        case let .int(value):
            try container.encode(value)
        case let .double(value):
            try container.encode(value)
        case let .bool(value):
            try container.encode(value)
        case .unknown:
            return
        }
    }

    public var stringValue: String? {
        if case let .string(value) = self {
            return value
        } else {
            return nil
        }
    }

    public var intValue: Int? {
        if case let .int(value) = self {
            return value
        } else {
            return nil
        }
    }

    public var doubleValue: Double? {
        switch self {
        case let .int(value):
            return Double(value)
        case let .double(value):
            return value
        default:
            return nil
        }
    }

    public var boolValue: Bool? {
        if case let .bool(value) = self {
            return value
        } else {
            return nil
        }
    }
}

public struct GeneralTokenExtension: Hashable, Codable {
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

    public init(data: [String: TokenExtensionValue]) {
        website = data["stringValue"]?.stringValue
        bridgeContract = data["bridgeContract"]?.stringValue
        assetContract = data["assetContract"]?.stringValue
        address = data["address"]?.stringValue
        explorer = data["explorer"]?.stringValue
        twitter = data["twitter"]?.stringValue
        github = data["github"]?.stringValue
        medium = data["medium"]?.stringValue
        tgann = data["tgann"]?.stringValue
        tggroup = data["tggroup"]?.stringValue
        discord = data["discord"]?.stringValue
        serumV3Usdt = data["serumV3Usdt"]?.stringValue
        serumV3Usdc = data["serumV3Usdc"]?.stringValue
        coingeckoId = data["coingeckoId"]?.stringValue
        imageUrl = data["imageUrl"]?.stringValue
        description = data["description"]?.stringValue
    }

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
