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
    
    func testGetPrice() throws {
        let srmUSDCPair = try serumSwap.loadOrderbook(market: SRMUSDCMarket).toBlocking().first()
        XCTAssertNotNil(srmUSDCPair)
        
        let srmBbo = serumSwap.loadBbo(orderbookPair: srmUSDCPair!)
        print(srmBbo!)
        
        let btcUSDCPair = try serumSwap.loadOrderbook(market: BTCUSDCMarket).toBlocking().first()
        XCTAssertNotNil(btcUSDCPair)
        
        let btcBbo = serumSwap.loadBbo(orderbookPair: btcUSDCPair!)
        print(btcBbo!)
    }
}
