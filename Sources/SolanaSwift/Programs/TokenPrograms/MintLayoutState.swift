import Foundation

public protocol MintLayoutState: BufferLayout, Equatable, Hashable, Encodable {
    var mintAuthorityOption: UInt32 { get }
    var mintAuthority: PublicKey? { get }
    var supply: UInt64 { get }
    var decimals: UInt8 { get }
    var isInitialized: Bool { get }
    var freezeAuthorityOption: UInt32 { get }
    var freezeAuthority: PublicKey? { get }
}

extension MintLayoutState {
    func serializeCommonProperties(to writer: inout Data) throws {
        try mintAuthorityOption.serialize(to: &writer)
        if let mintAuthority = mintAuthority {
            try mintAuthority.serialize(to: &writer)
        } else {
            try PublicKey.NULL_PUBLICKEY_BYTES.forEach { try $0.serialize(to: &writer) }
        }
        try supply.serialize(to: &writer)
        try decimals.serialize(to: &writer)
        if isInitialized { try UInt8(1).serialize(to: &writer) } else { try UInt8(0).serialize(to: &writer) }
        try freezeAuthorityOption.serialize(to: &writer)
        if let freezeAuthority = freezeAuthority {
            try freezeAuthority.serialize(to: &writer)
        } else {
            try PublicKey.NULL_PUBLICKEY_BYTES.forEach { try $0.serialize(to: &writer) }
        }
    }
}
