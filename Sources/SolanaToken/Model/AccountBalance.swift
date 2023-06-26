//
//  File.swift
//
//
//  Created by Giang Long Tran on 26.06.2023.
//

import Foundation

@available(*, deprecated, renamed: "SolanaAccount")
public typealias Wallet = AccountBalance

public struct AccountBalance: Hashable {
    // MARK: - Properties

    public var pubkey: String?
    public var lamports: UInt64?
    public var token: TokenMetadata
    public let supply: UInt64?

    public var isNativeSOL: Bool {
        token.isNativeSOL
    }

    // MARK: - Initializer

    public init(pubkey: String? = nil, lamports: UInt64? = nil, supply: UInt64? = nil, token: TokenMetadata) {
        self.pubkey = pubkey
        self.lamports = lamports
        self.supply = supply
        self.token = token
    }

    // MARK: - Computed properties

    @available(*, deprecated, message: "Do not use double format for working")
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
