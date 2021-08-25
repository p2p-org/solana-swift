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
    var USDC: SolanaSDK.PublicKey { "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v"}
    var USDT: SolanaSDK.PublicKey { "Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB"}
    var WBTC: SolanaSDK.PublicKey { "9n4nbM75f5Ui33ZbPYXn59EwSgE8CGsHtAeTH5YFeJ9E"}
    var SRMDecimals: SolanaSDK.Decimals { 6 }
    var USDCDecimals: SolanaSDK.Decimals { 6 }

    var SRMUSDCMarket: SerumSwap.Market {
        SerumSwap.Market(
            decoded: SerumSwap.MarketStatLayoutV2(
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
}
