import Foundation

public struct Token2022MintState: TokenMintState {
    public let mintAuthorityOption: UInt32
    public let mintAuthority: PublicKey?
    public let supply: UInt64
    public let decimals: UInt8
    public let isInitialized: Bool
    public let freezeAuthorityOption: UInt32
    public let freezeAuthority: PublicKey?

    public var extensions: [AnyToken2022ExtensionState]

    public func getParsedExtension<T: Token2022ExtensionState>(ofType _: T.Type) -> T? {
        assert(T.self != UnparsedExtensionState.self)
        return extensions.first(where: { $0.state is T })?.state as? T
    }
}

extension Token2022MintState: BorshCodable {
    public init(from reader: inout BinaryReader) throws {
        let oldTokenMintState = try SPLTokenMintState(from: &reader)
        mintAuthorityOption = oldTokenMintState.mintAuthorityOption
        mintAuthority = oldTokenMintState.mintAuthority
        supply = oldTokenMintState.supply
        decimals = oldTokenMintState.decimals
        isInitialized = oldTokenMintState.isInitialized
        freezeAuthorityOption = oldTokenMintState.freezeAuthorityOption
        freezeAuthority = oldTokenMintState.freezeAuthority

        guard reader.cursor < reader.bytes.count else {
            extensions = []
            return
        }

        _ = try reader.read(count: 83) // padding
        _ = try reader.read(count: 1) // mint type

        var extensions = [AnyToken2022ExtensionState]()
        repeat {
            let ext = try AnyToken2022ExtensionState(from: &reader)
            extensions.append(ext)
        } while reader.cursor < reader.bytes.count

        self.extensions = extensions
    }

    public func serialize(to writer: inout Data) throws {
        try serializeCommonProperties(to: &writer)
        try Data(repeating: UInt8(0), count: 83).serialize(to: &writer)
        try UInt8(1).serialize(to: &writer)
        for ext in extensions {
            try ext.serialize(to: &writer)
        }
    }
}
