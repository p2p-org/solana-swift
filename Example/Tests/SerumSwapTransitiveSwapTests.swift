//
//  SerumSwapTransitiveSwapTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 31/08/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
@testable import SolanaSwift

class SerumSwapTransitiveSwapTests: SerumSwapTests {
    /// Create from and to open orders and wait for comfirmation before transitive swaping
    func testCreateFromAndToOpenOrders() throws {
        let toMarket = try serumSwap.loadMarket(fromMint: OXY, toMint: USDC).toBlocking().first()!.first!
        let result = try serumSwap.createFromAndToOpenOrdersForSwapTransitive(
            fromMarket: SRMUSDCMarket,
            toMarket: toMarket,
            feePayer: nil,
            close: true,
            isSimulation: true
        ).toBlocking().first()
        XCTAssertNotNil(result)
    }
    
    /// Swap SRM -> OXY
    func testSwapSRMOXY() throws {
        let tx = try serumSwap.swap(
            fromWallet: srmWallet,
            toWallet: oxyWallet,
            amount: 1,
            slippage: defaultSlippage,
            isSimulation: true
        ).toBlocking().first()
        XCTAssertNotNil(tx)
    }
    
    /// Swaps ETH -> BTC on the Serum orderbook.
    func testSwapETHToBTC() throws {
        let tx = try serumSwap.swap(
            fromWallet: ethWallet,
            toWallet: btcWallet,
            amount: 0.00005,
            slippage: defaultSlippage,
            isSimulation: true
        ).toBlocking().first()
        XCTAssertNotNil(tx)
    }
}
