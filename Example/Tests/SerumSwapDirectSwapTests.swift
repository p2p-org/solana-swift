//
//  SerumSwapDirectSwapTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 16/08/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import RxBlocking
import SolanaSwift

class SerumSwapDirectSwapTests: SerumSwapTests {
    /// Swaps SRM -> USDC on the Serum orderbook.
    func testSwapSRMToUSDC() throws {
        let tx = try serumSwap.swap(
            fromWallet: srmWallet,
            toWallet: usdcWallet,
            amount: 0.1,
            slippage: defaultSlippage,
            isSimulation: true
        ).toBlocking().first()
        XCTAssertNotNil(tx)
    }
    
    /// Swaps USDC -> SRM on the Serum orderbook.
    func testSwapUSDCToSRM() throws {
        let tx = try serumSwap.swap(
            fromWallet: usdcWallet,
            toWallet: srmWallet,
            amount: 2,
            slippage: defaultSlippage,
            isSimulation: true
        ).toBlocking().first()
        XCTAssertNotNil(tx)
    }
    
    /// Swaps SOL -> USDC on the Serum orderbook.
    func testSwapSOLUSDC() throws {
        let tx = try serumSwap.swap(
            fromWallet: solNativeWallet,
            toWallet: usdcWallet,
            amount: 0.1,
            slippage: defaultSlippage,
            isSimulation: true
        ).toBlocking().first()
        XCTAssertNotNil(tx)
    }
    
    /// Swaps USDC -> SOL on the Serum orderbook.
    func testSwapUSDCSOL() throws {
        let tx = try serumSwap.swap(
            fromWallet: usdcWallet,
            toWallet: solNativeWallet,
            amount: 4,
            slippage: defaultSlippage,
            isSimulation: true
        ).toBlocking().first()
        XCTAssertNotNil(tx)
    }
    
    /// Special case: Swaps USDT -> USDC on the Serum orderbook.
    func testSwapUSDTToUSDC() throws {
        let tx = try serumSwap.swap(
            fromWallet: usdtWallet,
            toWallet: usdcWallet,
            amount: 7,
            slippage: defaultSlippage,
            isSimulation: true
        ).toBlocking().first()
        XCTAssertNotNil(tx)
    }
    
    /// Special case: Swaps USDС -> USDT on the Serum orderbook.
    func testSwapUSDCToUSDT() throws {
        let tx = try serumSwap.swap(
            fromWallet: usdcWallet,
            toWallet: usdtWallet,
            amount: 5,
            slippage: defaultSlippage,
            isSimulation: true
        ).toBlocking().first()
        XCTAssertNotNil(tx)
    }
}
