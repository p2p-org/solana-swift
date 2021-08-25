//
//  SerumSwapOrderbookTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 23/08/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
@testable import SolanaSwift

class SerumSwapOrderbookTests: SerumSwapTests {
    var market: SerumSwap.Market {SRMUSDCMarket}
    
    func testGetOrderbookPair() throws {
        let orderbookPairRequest = serumSwap.loadOrderbook(market: market)
        XCTAssertNoThrow(try orderbookPairRequest.toBlocking().first())
    }
}
