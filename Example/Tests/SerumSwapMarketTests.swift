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
    func testGetMarket() throws {
        // Swaps SRM -> USDC on the Serum orderbook.
        let marketAddresses = try serumSwap.route(fromMint: SRM, toMint: USDC).toBlocking().first()!!
        let marketAddress = marketAddresses[0]
        let market = try serumSwap.loadMarket(address: marketAddress).toBlocking().first()
        XCTAssertNotNil(market)
    }
    
    func testGetPriceFromCachedMarket() throws {
        let srmUSDCPair = try serumSwap.loadOrderbook(market: SRMUSDCMarket).toBlocking().first()
        XCTAssertNotNil(srmUSDCPair)
        
        let srmBbo = serumSwap.loadBbo(orderbookPair: srmUSDCPair!)
        
        let btcUSDCPair = try serumSwap.loadOrderbook(market: BTCUSDCMarket).toBlocking().first()
        XCTAssertNotNil(btcUSDCPair)
        
        let btcBbo = serumSwap.loadBbo(orderbookPair: btcUSDCPair!)
        print(srmBbo!)
        print(btcBbo!)
    }
    
    func testGetPriceFromNewMarket() throws {
        let price = try serumSwap.loadFair(fromMint: SOL, toMint: SRM).toBlocking().first()
        print(price)
        
    }
    
    func testCalculateExchangeRate() throws {
        let fair: Double = 0.11853959222380275
        let expectedRate: UInt64 = 8375352
        let realRate = serumSwap.calculateExchangeRate(
            fair: fair,
            slippage: 0.005,
            toDecimal: 6
        )
        XCTAssertEqual(expectedRate, realRate)
//        let realRate = serumSwap.calculateExchangeRate(
//            fair: fair,
//            slippage: 0.005,
//            fromDecimals: 6,
//            toDecimal: 6,
//            strict: true
//        )
//        XCTAssertEqual(realRate.rate, expectedRate)
    }
}
