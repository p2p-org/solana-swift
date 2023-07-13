import Foundation

@available(*, deprecated, renamed: "AccountBalance")
public typealias Wallet = AccountBalance

public struct AccountBalance: Hashable, Equatable {
    // MARK: - Properties

    public var pubkey: String?
    public var lamports: UInt64?
    public var token: TokenMetadata
    public var userInfo: AnyHashable?
    public let supply: UInt64?

    public var isNativeSOL: Bool {
        token.isNativeSOL
    }

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

    // MARK: - Fabric methods

    public static func nativeSolana(
        pubkey: String?,
        lamport: UInt64?
    ) -> AccountBalance {
        AccountBalance(
            pubkey: pubkey,
            lamports: lamport,
            token: .nativeSolana
        )
    }
}