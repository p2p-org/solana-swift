//
//  Wallet.swift
//  SolanaSwift
//
//  Created by Chung Tran on 22/04/2021.
//

import Foundation

extension SolanaSDK {
    public struct Wallet: Hashable {
        // MARK: - Properties
        public var pubkey: String?
        public var lamports: UInt64?
        public var token: Token
        public var userInfo: AnyHashable?
        
        public var isNativeSOL: Bool {
            token.isNativeSOL
        }
        
        // MARK: - Initializer
        public init(pubkey: String? = nil, lamports: UInt64? = nil, token: SolanaSDK.Token) {
            self.pubkey = pubkey
            self.lamports = lamports
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
}
