import Foundation

public struct TokenAccountState: TokenAccountLayoutState {
    public static let BUFFER_LENGTH: UInt64 = 165

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

extension TokenAccountState: BorshCodable {
    public func serialize(to writer: inout Data) throws {
        try serializeCommonProperties(to: &writer)
    }

    public init(from reader: inout BinaryReader) throws {
        mint = try .init(from: &reader)
        owner = try .init(from: &reader)
        lamports = try .init(from: &reader)
        delegateOption = try .init(from: &reader)
        let tempdelegate = try? PublicKey(from: &reader)
        state = try .init(from: &reader)
        isNativeOption = try .init(from: &reader)
        isNativeRaw = try .init(from: &reader)
        delegatedAmount = try .init(from: &reader)
        closeAuthorityOption = try .init(from: &reader)
        closeAuthority = try? PublicKey(from: &reader)

        if delegateOption == 0 {
            delegate = nil
            delegatedAmount = 0
        } else {
            delegate = tempdelegate
        }

        isInitialized = state != 0
        isFrozen = state == 2

        if isNativeOption == 1 {
            rentExemptReserve = isNativeRaw
            isNative = true
        } else {
            rentExemptReserve = nil
            isNative = false
        }

        if closeAuthorityOption == 0 {
            closeAuthority = nil
        }
    }
}
