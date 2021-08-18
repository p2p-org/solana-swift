//
//  SerumSwapTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 16/08/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import RxBlocking
import SolanaSwift

class SerumSwapTests: RestAPITests {
    override var overridingAccount: String? {
        "miracle pizza supply useful steak border same again youth silver access hundred"
    }
    
    var serumSwap: SerumSwap!
    
    let SRM: SolanaSDK.PublicKey = "SRMuApVNdxXokk5GT7XD5cUUgXMBCoAz2LHeuAoKWRt"
    let USDC: SolanaSDK.PublicKey = "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v"
    let USDT: SolanaSDK.PublicKey = "Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB"
    let WBTC: SolanaSDK.PublicKey = "9n4nbM75f5Ui33ZbPYXn59EwSgE8CGsHtAeTH5YFeJ9E"
    let decimals: SolanaSDK.Decimals = 6
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        serumSwap = .init(client: solanaSDK, accountProvider: solanaSDK, tokenListContainer: solanaSDK)
    }

    func testDirectSwap() throws {
        // Swaps SRM -> USDC on the Serum orderbook.
        let marketAddresses = try serumSwap.route(fromMint: SRM, toMint: USDC).toBlocking().first()!!
        let marketAddress = marketAddresses[0]
        let market = try serumSwap.loadMarket(address: marketAddress).toBlocking().first()
        
        let request = serumSwap.swap(
            .init(
                fromMint: SRM,
                toMint: USDC,
                quoteMint: nil,
                amount: 1,
                minExchangeRate: .init(
                    rate: 1,
                    fromDecimals: decimals,
                    quoteDecimals: decimals,
                    strict: false
                ),
                referral: nil,
                fromWallet: "D2RGqjKxvP1At8BwSx95FUYwbgwLK1N9jB7QH5Lt3UQw",
                toWallet: "3uetDDizgTtadDHZzyy9BqxrjQcozMEkxzbKhfZF4tG3",
                quoteWallet: nil,
                fromMarket: market!,
                toMarket: nil,
                fromOpenOrders: nil,
                toOpenOrders: nil,
                close: true
            )
        )
        let signersAndInstructions = try request.toBlocking().first()
        
    }
    
    func testTransitiveSwap() throws {
        // Transitive swap from SRM -> USDC -> BTC.
    }

}
