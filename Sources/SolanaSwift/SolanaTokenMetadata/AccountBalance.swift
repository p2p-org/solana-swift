import Foundation

@available(*, deprecated, renamed: "TokenAccount")
public typealias Wallet = AccountBalance

public struct AccountBalance: Hashable, Equatable {
    // MARK: - Properties

    public var pubkey: String?
    public var lamports: UInt64?
    public var token: TokenMetadata
    public var userInfo: AnyHashable?
    public let supply: UInt64?

    // MARK: - Initializer

    public init(
        pubkey: String? = nil,
        lamports: UInt64? = nil,
        supply: UInt64? = nil,
        token: TokenMetadata
    ) {
        self.pubkey = pubkey
        self.lamports = lamports
        self.supply = supply
        self.token = token
    }

    // MARK: - Computed properties

    public var amount: Double? {
        lamports?.convertToBalance(decimals: token.decimals)
    }

    public var isNativeSOL: Bool {
        token.isNative
    }
}
