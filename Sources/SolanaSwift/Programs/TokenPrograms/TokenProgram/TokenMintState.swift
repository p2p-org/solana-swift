import Foundation

public struct TokenMintState: MintLayoutState {
    public static var BUFFER_LENGTH: UInt64 = 82

    public let mintAuthorityOption: UInt32
    public let mintAuthority: PublicKey?
    public let supply: UInt64
    public let decimals: UInt8
    public let isInitialized: Bool
    public let freezeAuthorityOption: UInt32
    public let freezeAuthority: PublicKey?
}

extension TokenMintState: BorshCodable {
    public init(from reader: inout BinaryReader) throws {
        mintAuthorityOption = try .init(from: &reader)
        mintAuthority = try? PublicKey(from: &reader)
        supply = try .init(from: &reader)
        decimals = try .init(from: &reader)
        isInitialized = try UInt8(from: &reader) == 1
        freezeAuthorityOption = try .init(from: &reader)
        let freezeAuthorityTemp = try? PublicKey(from: &reader)
        if freezeAuthorityOption == 0 {
            freezeAuthority = nil
        } else {
            freezeAuthority = freezeAuthorityTemp
        }
    }

    public func serialize(to writer: inout Data) throws {
        try serializeCommonProperties(to: &writer)
    }
}
