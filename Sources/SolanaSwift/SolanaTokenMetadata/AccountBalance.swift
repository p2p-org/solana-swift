import Foundation

public struct AccountBalance: Hashable, Equatable {
    // MARK: - Properties

    public var pubkey: String?
    public var lamports: UInt64?
    public var token: TokenMetadata
    public var userInfo: AnyHashable?
    public let supply: UInt64?
    public let tokenProgramId: String?
    public let minimumBalanceForRentExemption: UInt64

    // MARK: - Initializer

    public init(
        pubkey: String? = nil,
        lamports: UInt64? = nil,
        supply: UInt64? = nil,
        token: TokenMetadata,
        tokenProgramId: String?,
        minimumBalanceForRentExemption: UInt64
    ) {
        self.pubkey = pubkey
        self.lamports = lamports
        self.supply = supply
        self.token = token
        self.tokenProgramId = tokenProgramId
        self.minimumBalanceForRentExemption = minimumBalanceForRentExemption
    }
}

public struct UnknownAccountBalance {
    public let pubkey: String
    public let lamports: Lamports

    public let mintAddress: String
    public let decimals: Decimals

    public let supply: UInt64?
    public let tokenProgramId: String?
    public let minimumBalanceForRentExemption: UInt64
}
