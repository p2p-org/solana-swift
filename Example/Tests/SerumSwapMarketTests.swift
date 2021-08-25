//
//  SerumSwapMarketTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 18/08/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
@testable import SolanaSwift

class SerumSwapMarketTests: SerumSwapTests {
    var market: SerumSwap.Market {SRMUSDCMarket}
    
    func testGetMarket() throws {
        // Swaps SRM -> USDC on the Serum orderbook.
        let marketAddresses = try serumSwap.route(fromMint: SRM, toMint: USDC).toBlocking().first()!!
        let marketAddress = marketAddresses[0]
        let marketRequest = serumSwap.loadMarket(address: marketAddress)
        XCTAssertNoThrow(try marketRequest.toBlocking().first())
    }
    
    func testGetPrice() throws {
        let price = market.priceLotsToNumber(price: 7122)
        XCTAssertEqual(price, 7.122)
    }
}
