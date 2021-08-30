//
//  SerumSwapTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 25/08/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
@testable import SolanaSwift

class SerumSwapTests: RestAPITests {
    override var overridingAccount: String? {
        "miracle pizza supply useful steak border same again youth silver access hundred"
    }
    
    var serumSwap: SerumSwap!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        serumSwap = .init(client: solanaSDK, accountProvider: solanaSDK, tokenListContainer: solanaSDK)
    }
    
    var SRM: SolanaSDK.PublicKey { "SRMuApVNdxXokk5GT7XD5cUUgXMBCoAz2LHeuAoKWRt" }
    var SOL: SolanaSDK.PublicKey { "So11111111111111111111111111111111111111112" }
    var BTC: SolanaSDK.PublicKey { "9n4nbM75f5Ui33ZbPYXn59EwSgE8CGsHtAeTH5YFeJ9E" }
    var USDC: SolanaSDK.PublicKey { "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v"}
    var USDT: SolanaSDK.PublicKey { "Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB"}
    var WBTC: SolanaSDK.PublicKey { "9n4nbM75f5Ui33ZbPYXn59EwSgE8CGsHtAeTH5YFeJ9E"}
    var SRMDecimals: SolanaSDK.Decimals { 6 }
    var USDCDecimals: SolanaSDK.Decimals { 6 }

    var SRMUSDCMarket: SerumSwap.Market {
        SerumSwap.Market(
            decoded: SerumSwap.Market.LayoutV2(
                blob5: .init(bytes: [115, 101, 114, 117, 109]),
                accountFlags: .init(
                    initialized: true,
                    market: true,
                    openOrders: false,
                    requestQueue: false,
                    eventQueue: false,
                    bids: false,
                    asks: false
                ),
                ownAddress: "ByRys5tuUWDgL73G8JBAEfkdFf8JWBzPBDHsBVQ5vbQA",
                vaultSignerNonce: 0,
                baseMint: "SRMuApVNdxXokk5GT7XD5cUUgXMBCoAz2LHeuAoKWRt",
                quoteMint: "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v",
                baseVault: "Ecfy8et9Mft9Dkavnuh4mzHMa2KWYUbBTA5oDZNoWu84",
                baseDepositsTotal: 31441200000,
                baseFeesAccrued: 0,
                quoteVault: "hUgoKy5wjeFbZrXDW4ecr42T4F5Z1Tos31g68s5EHbP",
                quoteDepositsTotal: 605943927629,
                quoteFeesAccrued: 2314109580,
                quoteDustThreshold: 100,
                requestQueue: "Hr8Z93aWe4hhJbC5i7YTsPaSToziVh3vyMfv9GRqKFCh",
                eventQueue: "6o44a9xdzKKDNY7Ff2Qb129mktWbsCT4vKJcg2uk41uy",
                bids: "AuL9JzRJ55MdqzubK4EutJgAumtkuFcRVuPUvTX39pN8",
                asks: "8Lx9U9wdE3afdqih1mCAXy3unJDfzSaXFqAvoLMjhwoD",
                baseLotSize: 100000,
                quoteLotSize: 100,
                feeRateBps: 0,
                referrerRebatesAccrued: 1119325855,
                blob7: .init(bytes: [112, 97, 100, 100, 105, 110, 103])
            ),
            baseMintDecimals: 6,
            quoteMintDecimals: 6,
            programId: .dexPID
        )
    }
    
    var BTCUSDCMarket: SerumSwap.Market {
        SerumSwap.Market(
            decoded: SerumSwap.Market.LayoutV2(
                blob5: .init(bytes: [115, 101, 114, 117, 109]),
                accountFlags: .init(
                    initialized: true,
                    market: true,
                    openOrders: false,
                    requestQueue: false,
                    eventQueue: false,
                    bids: false,
                    asks: false
                ),
                ownAddress: "A8YFbxQYFVqKZaoYJLLUVcQiWP7G2MeEgW5wsAQgMvFw",
                vaultSignerNonce: 0,
                baseMint: "9n4nbM75f5Ui33ZbPYXn59EwSgE8CGsHtAeTH5YFeJ9E",
                quoteMint: "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v",
                baseVault: "GZ1YSupuUq9kB28kX9t1j9qCpN67AMMwn4Q72BzeSpfR",
                baseDepositsTotal: 537318800,
                baseFeesAccrued: 0,
                quoteVault: "7sP9fug8rqZFLbXoEj8DETF81KasaRA1fr6jQb6ScKc5",
                quoteDepositsTotal: 12634544048534,
                quoteFeesAccrued: 5387527075,
                quoteDustThreshold: 100,
                requestQueue: "H6UaUrNVELJgTqao1CNL4252kShLKSfwoboT8tF7HNtB",
                eventQueue: "6NQqaa48SnBBJZt9HyVPngcZFW81JfDv9EjRX2M4WkbP",
                bids: "6wLt7CX1zZdFpa6uGJJpZfzWvG6W9rxXjquJDYiFwf9K",
                asks: "6EyVXMMA58Nf6MScqeLpw1jS12RCpry23u9VMfy8b65Y",
                baseLotSize: 100,
                quoteLotSize: 10,
                feeRateBps: 0,
                referrerRebatesAccrued: 1466925674,
                blob7: .init(bytes: [112, 97, 100, 100, 105, 110])
            ),
            baseMintDecimals: 6,
            quoteMintDecimals: 6,
            programId: .dexPID
        )
    }
}
