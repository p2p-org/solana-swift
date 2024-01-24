import Foundation

public struct Token2022MintState: MintLayoutState {
    private static var ACCOUNT_TYPE: UInt8 { 1 }

    public let mintAuthorityOption: UInt32
    public let mintAuthority: PublicKey?
    public let supply: UInt64
    public let decimals: UInt8
    public let isInitialized: Bool
    public let freezeAuthorityOption: UInt32
    public let freezeAuthority: PublicKey?

    public var extensions: [AnyToken2022ExtensionState]

    public func getParsedExtension<T: Token2022ExtensionState>(ofType _: T.Type) -> T? {
        assert(T.self != VecU8<UInt16>.self)
        return extensions.first(where: { $0.state is T })?.state as? T
    }
}

extension Token2022MintState: BorshCodable {
    public init(from reader: inout BinaryReader) throws {
        let oldTokenMintState = try TokenMintState(from: &reader)
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

        let accountType = try reader.read(count: 1)

        // AccountType == 1 for MintState
        guard accountType.first == Self.ACCOUNT_TYPE else {
            throw BinaryReaderError.dataMismatch
        }

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
        try Self.ACCOUNT_TYPE.serialize(to: &writer)
        for ext in extensions {
            try ext.serialize(to: &writer)
        }
    }
}
