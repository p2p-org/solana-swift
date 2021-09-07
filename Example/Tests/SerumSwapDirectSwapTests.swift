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

class SrumSwapSwapTests: SerumSwapTests {
    let defaultSlippage = 0.005
    
    var srmWallet: SolanaSDK.Wallet {wallets.first(where: {$0.token.address == SRM.base58EncodedString})!}
    var usdcWallet: SolanaSDK.Wallet {wallets.first(where: {$0.token.address == USDC.base58EncodedString})!}
    var usdtWallet: SolanaSDK.Wallet {wallets.first(where: {$0.token.address == USDT.base58EncodedString})!}
    var btcWallet: SolanaSDK.Wallet {wallets.first(where: {$0.token.address == BTC.base58EncodedString})!}
    var ethWallet: SolanaSDK.Wallet {wallets.first(where: {$0.token.address == ETH.base58EncodedString})!}
    var oxyWallet: SolanaSDK.Wallet {wallets.first(where: {$0.token.address == OXY.base58EncodedString})!}
}

class SerumSwapDirectSwapTests: SrumSwapSwapTests {
    /// Swaps SRM -> USDC on the Serum orderbook.
    func testSwapSRMUSDC() throws {
        let tx = try serumSwap.swap(
            fromWallet: srmWallet,
            toWallet: usdcWallet,
            amount: 0.1,
            slippage: defaultSlippage,
            isSimulation: true
        ).toBlocking().first()
        XCTAssertNotNil(tx)
    }
    
    /// Swaps SRM -> USDT on the Serum orderbook.
    func testSwapSRMUSDT() throws {
        let tx = try serumSwap.swap(
            fromWallet: srmWallet,
            toWallet: usdtWallet,
            amount: 0.1,
            slippage: defaultSlippage,
            isSimulation: true
        ).toBlocking().first()
        XCTAssertNotNil(tx)
    }
    
    /// Swaps USDC -> SRM on the Serum orderbook.
    func testSwapUSDCSRM() throws {
        let tx = try serumSwap.swap(
            fromWallet: usdcWallet,
            toWallet: srmWallet,
            amount: 2,
            slippage: defaultSlippage,
            isSimulation: true
        ).toBlocking().first()
        XCTAssertNotNil(tx)
    }
    
    /// Swaps USDT -> SRM on the Serum orderbook.
    func testSwapUSDTSRM() throws {
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
    
    /// Swaps SOL -> USDC on the Serum orderbook.
    func testSwapSOLUSDT() throws {
        let tx = try serumSwap.swap(
            fromWallet: solNativeWallet,
            toWallet: usdtWallet,
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
            amount: 7,
            slippage: defaultSlippage,
            isSimulation: true
        ).toBlocking().first()
        XCTAssertNotNil(tx)
    }
    
    /// Swaps USDT -> SOL on the Serum orderbook.
    func testSwapUSDTSOL() throws {
        let tx = try serumSwap.swap(
            fromWallet: usdtWallet,
            toWallet: solNativeWallet,
            amount: 7,
            slippage: defaultSlippage,
            isSimulation: true
        ).toBlocking().first()
        XCTAssertNotNil(tx)
    }
    
    /// Special case: Swaps USDT -> USDC on the Serum orderbook.
    func testSwapUSDTUSDC() throws {
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
    func testSwapUSDCUSDT() throws {
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
