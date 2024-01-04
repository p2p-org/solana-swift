import Foundation

public struct Token2022MintState: SolanaSPLTokenMintState {
    // TODO: - Fix buffer_length here
    public static var BUFFER_LENGTH: UInt64 = 82

    public let mintAuthorityOption: UInt32
    public let mintAuthority: PublicKey?
    public let supply: UInt64
    public let decimals: UInt8
    public let isInitialized: Bool
    public let freezeAuthorityOption: UInt32
    public let freezeAuthority: PublicKey?
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
    }

    public func serialize(to writer: inout Data) throws {
        try serializeCommonProperties(to: &writer)
        // TODO: - Serialize token-2022 extensions here
    }
}
