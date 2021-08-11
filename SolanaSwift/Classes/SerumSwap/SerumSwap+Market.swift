//
//  SerumSwap+Market.swift
//  SolanaSwift
//
//  Created by Chung Tran on 11/08/2021.
//

import Foundation
import RxSwift

extension SerumSwap {
    struct Market {
        // MARK: - Nested type
        private typealias OpenOrdersAccountsCache = [String: (accounts: [OpenOrders], ts: UInt64)] // cache by PublicKey (String)
        private typealias FeeDiscountKeysCache = [String: (accounts: [FeeDiscountAccount], ts: UInt64)]
                
        // MARK: - Properties
        private let decoded: SerumSwapMarketStatLayout
        private let baseSplTokenDecimals: Decimals
        private let quoteSplTokenDecimals: Decimals
        private let skipPreflight: Bool
        private let commitment: SolanaSDK.Commitment
        private let programId: PublicKey
        private let layoutOverride: SerumSwapMarketStatLayout.Type?
        private let openOrdersAccountsCache: OpenOrdersAccountsCache = [:]
        private let feeDiscountKeysCache: FeeDiscountKeysCache = [:]
        
        // MARK: - Initializer
        init(
            decoded: SerumSwapMarketStatLayout,
            baseMintDecimals baseSplTokenDecimals: SerumSwap.Decimals,
            quoteMintDecimals quoteSplTokenDecimals: SerumSwap.Decimals,
            skipPreflight: Bool = false,
            commitment: SolanaSDK.Commitment = "recent",
            programId: SerumSwap.PublicKey,
            layoutOverride: SerumSwapMarketStatLayout.Type? = nil
        ) {
            self.decoded = decoded
            self.baseSplTokenDecimals = baseSplTokenDecimals
            self.quoteSplTokenDecimals = quoteSplTokenDecimals
            self.skipPreflight = skipPreflight
            self.commitment = commitment
            self.programId = programId
            self.layoutOverride = layoutOverride
        }
        
        private static func getLayoutType(programId: String) -> SerumSwapMarketStatLayout.Type {
            let version = SerumSwap.getVersion(programId: programId)
            if version == 1 {return MarketStatLayoutV1.self}
            return MarketStatLayoutV2.self
        }

        private static func getLayoutSpan(programId: String) -> UInt64 {
            getLayoutType(programId: programId).span
        }
        
//        static func findAccountsByMints(
//            client: SerumSwapAPIClient,
//            baseMintAddress: PublicKey,
//            quoteMintAddress: PublicKey,
//            programId: PublicKey
//        ) {
//            let filter: [[String: Encodable]] = [
//                [
//                    "memcmp": EncodableWrapper(
//                        wrapped: [
//                            "offset": EncodableWrapper(wrapped: PublicKey.numberOfBytes),
//                             "bytes": EncodableWrapper(wrapped: baseMintAddress.base58EncodedString)
//                        ]
//                    )
//                ],
//                [
//                    "memcmp": EncodableWrapper(
//                        wrapped: [
//                            "offset": EncodableWrapper(wrapped: PublicKey.numberOfBytes),
//                             "bytes": EncodableWrapper(wrapped: quoteMintAddress.base58EncodedString)
//                        ]
//                    )
//                ]
//            ]
//
//        }
        
        static func load(
            client: SerumSwapAPIClient,
            address: PublicKey,
            skipPreflight: Bool = false,
            commitment: SolanaSDK.Commitment = "recent",
            programId: PublicKey,
            layoutOverride: SerumSwapMarketStatLayout.Type?
        ) -> Single<Market> {
            // layout type
            let layoutType = layoutOverride ?? getLayoutType(programId: programId.base58EncodedString)
            
            // address info
            let requestAddressInfo: Single<SerumSwapMarketStatLayout>
            
            if layoutType == MarketStatLayoutV1.self {
                requestAddressInfo = getAccountInfoAndVerifyOwner(
                    client: client,
                    account: address,
                    owner: programId,
                    decodedTo: MarketStatLayoutV1.self
                )
                .map {$0 as SerumSwapMarketStatLayout}
            } else if layoutType == MarketStatLayoutV2.self {
                requestAddressInfo = getAccountInfoAndVerifyOwner(
                    client: client,
                    account: address,
                    owner: programId,
                    decodedTo: MarketStatLayoutV2.self
                )
                .map {$0 as SerumSwapMarketStatLayout}
            } else {
                requestAddressInfo = getAccountInfoAndVerifyOwner(
                    client: client,
                    account: address,
                    owner: programId,
                    decodedTo: MarketStatLayoutV3.self
                )
                .map {$0 as SerumSwapMarketStatLayout}
            }
            
            return requestAddressInfo
                .flatMap {decoded -> Single<(SerumSwapMarketStatLayout, Decimals, Decimals)> in
                    guard decoded.accountFlags.initialized,
                          decoded.accountFlags.market,
                          decoded.ownAddress == address
                    else {
                        throw SerumSwapError("Invalid market")
                    }
                    return Single.zip(
                        .just(decoded),
                        client.getDecimals(
                            mintAddress: decoded.baseMint.base58EncodedString,
                            programId: decoded.baseMint.base58EncodedString
                        ),
                        client.getDecimals(
                            mintAddress: decoded.baseMint.base58EncodedString,
                            programId: decoded.quoteMint.base58EncodedString
                        )
                    )
                }
                .map {decoded, baseDecimal, quoteDecimal in
                    Market(
                        decoded: decoded,
                        baseMintDecimals: baseDecimal,
                        quoteMintDecimals: quoteDecimal,
                        skipPreflight: skipPreflight,
                        commitment: commitment,
                        programId: programId,
                        layoutOverride: layoutOverride
                    )
                }
            
        }
        
        private static func getAccountInfoAndVerifyOwner<T: DecodableBufferLayout>(
            client: SerumSwapAPIClient,
            account: PublicKey,
            owner: PublicKey,
            decodedTo type: T.Type
        ) -> Single<T> {
            client.getAccountInfo(
                account: account.base58EncodedString,
                decodedTo: type
            )
            .map { info in
                guard info.owner == owner.base58EncodedString else {
                    throw SerumSwapError("Address not owned by program")
                }
                return info.data
            }
        }
    }
}


// MARK: - Models
protocol SerumSwapMarketStatLayout {
    static var span: UInt64 {get}
    var accountFlags: SerumSwap.AccountFlags {get}
    var ownAddress: SerumSwap.PublicKey {get}
    var vaultSignerNonce: UInt64 {get}
    var baseMint: SerumSwap.PublicKey {get}
    var quoteMint: SerumSwap.PublicKey {get}
    var baseVault: SerumSwap.PublicKey {get}
    var baseDepositsTotal: UInt64 {get}
    var baseFeesAccrued: UInt64 {get}
    var quoteVault: SerumSwap.PublicKey {get}
    var quoteDepositsTotal: UInt64 {get}
    var quoteFeesAccrued: UInt64 {get}
    var quoteDustThreshold: UInt64 {get}
    var requestQueue: SerumSwap.PublicKey {get}
    var eventQueue: SerumSwap.PublicKey {get}
    var bids: SerumSwap.PublicKey {get}
    var asks: SerumSwap.PublicKey {get}
    var baseLotSize: UInt64 {get}
    var quoteLotSize: UInt64 {get}
    var feeRateBps: UInt64 {get}
}

extension SerumSwap {
    struct MarketStatLayoutV1: SerumSwapMarketStatLayout, DecodableBufferLayout {
        let blob5: Blob5
        let accountFlags: AccountFlags
        let ownAddress: PublicKey
        let vaultSignerNonce: UInt64
        let baseMint: PublicKey
        let quoteMint: PublicKey
        let baseVault: PublicKey
        let baseDepositsTotal: UInt64
        let baseFeesAccrued: UInt64
        let quoteVault: PublicKey
        let quoteDepositsTotal: UInt64
        let quoteFeesAccrued: UInt64
        let quoteDustThreshold: UInt64
        let requestQueue: PublicKey
        let eventQueue: PublicKey
        let bids: PublicKey
        let asks: PublicKey
        let baseLotSize: UInt64
        let quoteLotSize: UInt64
        let feeRateBps: UInt64
        let blob7: Blob7
    }
    
    struct MarketStatLayoutV2: SerumSwapMarketStatLayout, DecodableBufferLayout {
        let blob5: Blob5
        let accountFlags: AccountFlags
        let ownAddress: PublicKey
        let vaultSignerNonce: UInt64
        let baseMint: PublicKey
        let quoteMint: PublicKey
        let baseVault: PublicKey
        let baseDepositsTotal: UInt64
        let baseFeesAccrued: UInt64
        let quoteVault: PublicKey
        let quoteDepositsTotal: UInt64
        let quoteFeesAccrued: UInt64
        let quoteDustThreshold: UInt64
        let requestQueue: PublicKey
        let eventQueue: PublicKey
        let bids: PublicKey
        let asks: PublicKey
        let baseLotSize: UInt64
        let quoteLotSize: UInt64
        let feeRateBps: UInt64
        let referrerRebatesAccrued: UInt64
        let blob7: Blob7
    }
    
    struct MarketStatLayoutV3: SerumSwapMarketStatLayout, DecodableBufferLayout {
        let blob5: Blob5
        let accountFlags: AccountFlags
        let ownAddress: PublicKey
        let vaultSignerNonce: UInt64
        let baseMint: PublicKey
        let quoteMint: PublicKey
        let baseVault: PublicKey
        let baseDepositsTotal: UInt64
        let baseFeesAccrued: UInt64
        let quoteVault: PublicKey
        let quoteDepositsTotal: UInt64
        let quoteFeesAccrued: UInt64
        let quoteDustThreshold: UInt64
        let requestQueue: PublicKey
        let eventQueue: PublicKey
        let bids: PublicKey
        let asks: PublicKey
        let baseLotSize: UInt64
        let quoteLotSize: UInt64
        let feeRateBps: UInt64
        let referrerRebatesAccrued: UInt64
        let authority: PublicKey
        let pruneAuthority: PublicKey
        let blob1024: Blob1024
        let blob7: Blob7
    }
    
    struct FeeDiscountAccount {
        let balance: Lamports
        let mint: PublicKey
        let pubkey: PublicKey
        let feeTier: Lamports
    }
}
