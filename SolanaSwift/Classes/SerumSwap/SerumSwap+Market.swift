//
//  SerumSwap+Market.swift
//  SolanaSwift
//
//  Created by Chung Tran on 11/08/2021.
//

import Foundation

extension SerumSwap {
    struct Market {
        
    }
}

protocol SerumSwapMarketStatLayout {
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
}
