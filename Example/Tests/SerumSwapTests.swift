//
//  SerumSwapTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 16/08/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import RxBlocking
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
    
    func testGetMarket() throws {
        // Swaps SRM -> USDC on the Serum orderbook.
        let marketAddresses = try serumSwap.route(fromMint: SRM, toMint: USDC).toBlocking().first()!!
        let marketAddress = marketAddresses[0]
        let marketRequest = serumSwap.loadMarket(address: marketAddress)
        XCTAssertNoThrow(try marketRequest.toBlocking().first())
    }
    
    func testGetOrderbookPair() throws {
        let orderbookPairRequest = serumSwap.loadOrderbook(market: market)
        XCTAssertNoThrow(try orderbookPairRequest.toBlocking().first())
    }
    
    func testGetPrice() throws {
        let price = market.priceLotsToNumber(price: 7122)
        XCTAssertEqual(price, 7.122)
    }

    func testDirectSwap() throws {
        // Swaps SRM -> USDC on the Serum orderbook.
        let request = serumSwap.swap(
            .init(
                fromMint: SRM,
                toMint: USDC,
                quoteMint: nil,
                amount: 1,
                minExchangeRate: .init(
                    rate: 7122000,
                    fromDecimals: SRMDecimals,
                    quoteDecimals: USDCDecimals,
                    strict: false
                ),
                referral: nil,
                fromWallet: "D2RGqjKxvP1At8BwSx95FUYwbgwLK1N9jB7QH5Lt3UQw",
                toWallet: "3uetDDizgTtadDHZzyy9BqxrjQcozMEkxzbKhfZF4tG3",
                quoteWallet: nil,
                fromMarket: market,
                toMarket: nil,
                fromOpenOrders: nil,
                toOpenOrders: nil,
                close: true
            )
        )
        let signersAndInstructions = try request.toBlocking().first()
        let tx = try solanaSDK.serializeTransaction(instructions: signersAndInstructions!.first!.instructions, signers: signersAndInstructions!.first!.signers).toBlocking().first()
        let txID = try solanaSDK.simulateTransaction(transaction: tx!).toBlocking().first()
    }
    
    func testTransitiveSwap() throws {
        // Transitive swap from SRM -> USDC -> BTC.
    }

}
