import Foundation

public protocol TokenAccountLayoutState: BufferLayout {
    var mint: PublicKey { get }
    var owner: PublicKey { get }
    var lamports: UInt64 { get }
    var delegateOption: UInt32 { get }
    var delegate: PublicKey? { get set }
    var isInitialized: Bool { get }
    var isFrozen: Bool { get }
    var state: UInt8 { get }
    var isNativeOption: UInt32 { get }
    var rentExemptReserve: UInt64? { get }
    var isNativeRaw: UInt64 { get }
    var isNative: Bool { get }
    var delegatedAmount: UInt64 { get set }
    var closeAuthorityOption: UInt32 { get }
    var closeAuthority: PublicKey? { get set }
}

extension TokenAccountLayoutState {
    func serializeCommonProperties(to writer: inout Data) throws {
        try mint.serialize(to: &writer)
        try owner.serialize(to: &writer)
        try lamports.serialize(to: &writer)
        try delegateOption.serialize(to: &writer)
        if let delegate = delegate {
            try delegate.serialize(to: &writer)
        } else {
            try PublicKey.NULL_PUBLICKEY_BYTES.forEach { try $0.serialize(to: &writer) }
        }
        try state.serialize(to: &writer)
        try isNativeOption.serialize(to: &writer)
        try isNativeRaw.serialize(to: &writer)
        try delegatedAmount.serialize(to: &writer)
        try closeAuthorityOption.serialize(to: &writer)
        if let closeAuthority = closeAuthority {
            try closeAuthority.serialize(to: &writer)
        } else {
            try PublicKey.NULL_PUBLICKEY_BYTES.forEach { try $0.serialize(to: &writer) }
        }
    }
}
