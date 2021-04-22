//
//  Wallet.swift
//  SolanaSwift
//
//  Created by Chung Tran on 22/04/2021.
//

import Foundation

extension SolanaSDK {
    public struct Wallet: Hashable {
        public var pubkey: String?
        public var lamports: UInt64?
        public var token: Token
        
        let liquidity: Bool?
        public var isLiquidity: Bool {
            liquidity == true
        }
        
        public static func nativeSolana(
            pubkey: String?,
            lamport: UInt64?
        ) -> Wallet {
            Wallet(
                pubkey: pubkey,
                lamports: lamport,
                token: .init(
                    _tags: [],
                    chainId: 101,
                    address: "So11111111111111111111111111111111111111112",
                    symbol: "SOL",
                    name: "Solana",
                    decimals: 9,
                    logoURI: nil,
                    tags: [],
                    extensions: nil
                ),
                liquidity: true
            )
        }
    }
}
