import Foundation

public struct Token2022AccountState: SolanaSPLTokenAccountState {
    public let mint: PublicKey
    public let owner: PublicKey
    public let lamports: UInt64
    public let delegateOption: UInt32
    public var delegate: PublicKey?
    public let isInitialized: Bool
    public let isFrozen: Bool
    public let state: UInt8
    public let isNativeOption: UInt32
    public let rentExemptReserve: UInt64?
    public let isNativeRaw: UInt64
    public let isNative: Bool
    public var delegatedAmount: UInt64
    public let closeAuthorityOption: UInt32
    public var closeAuthority: PublicKey?

    public init(
        mint: PublicKey,
        owner: PublicKey,
        lamports: UInt64,
        delegateOption: UInt32,
        delegate: PublicKey? = nil,
        isInitialized: Bool,
        isFrozen: Bool,
        state: UInt8,
        isNativeOption: UInt32,
        rentExemptReserve: UInt64? = nil,
        isNativeRaw: UInt64,
        isNative: Bool,
        delegatedAmount: UInt64,
        closeAuthorityOption: UInt32,
        closeAuthority: PublicKey? = nil
    ) {
        self.mint = mint
        self.owner = owner
        self.lamports = lamports
        self.delegateOption = delegateOption
        self.delegate = delegate
        self.isInitialized = isInitialized
        self.isFrozen = isFrozen
        self.state = state
        self.isNativeOption = isNativeOption
        self.rentExemptReserve = rentExemptReserve
        self.isNativeRaw = isNativeRaw
        self.isNative = isNative
        self.delegatedAmount = delegatedAmount
        self.closeAuthorityOption = closeAuthorityOption
        self.closeAuthority = closeAuthority
    }
}

extension Token2022AccountState: BorshCodable {
    public func serialize(to writer: inout Data) throws {
        try serializeCommonProperties(to: &writer)
        // TODO: - Serialize token-2022 extensions here
    }

    public init(from reader: inout BinaryReader) throws {
        let oldTokenProgramData = try SPLTokenAccountState(from: &reader)
        mint = oldTokenProgramData.mint
        owner = oldTokenProgramData.owner
        lamports = oldTokenProgramData.lamports
        delegateOption = oldTokenProgramData.delegateOption
        delegate = oldTokenProgramData.delegate
        isInitialized = oldTokenProgramData.isInitialized
        isFrozen = oldTokenProgramData.isFrozen
        state = oldTokenProgramData.state
        isNativeOption = oldTokenProgramData.isNativeOption
        rentExemptReserve = oldTokenProgramData.rentExemptReserve
        isNativeRaw = oldTokenProgramData.isNativeRaw
        isNative = oldTokenProgramData.isNative
        delegatedAmount = oldTokenProgramData.delegatedAmount
        closeAuthorityOption = oldTokenProgramData.closeAuthorityOption
        closeAuthority = oldTokenProgramData.closeAuthority
    }
}
