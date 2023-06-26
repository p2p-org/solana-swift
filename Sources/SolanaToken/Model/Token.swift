import Foundation
import SolanaSwift

/// Common token metadata structure.
///
/// 
public struct Token: Hashable, Codable {
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
    ) -> Token {
        Token(
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
