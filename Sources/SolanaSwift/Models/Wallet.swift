import Foundation

public struct Wallet: Hashable {
    // MARK: - Properties

    public var pubkey: String?
    public var lamports: UInt64?
    public var token: Token
    public var userInfo: AnyHashable?
    public let supply: UInt64?

    public var isNativeSOL: Bool {
        token.isNativeSOL
    }

    // MARK: - Initializer

    public init(pubkey: String? = nil, lamports: UInt64? = nil, supply: UInt64? = nil, token: Token) {
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
    ) -> Wallet {
        Wallet(
            pubkey: pubkey,
            lamports: lamport,
            token: .nativeSolana
        )
    }
}
