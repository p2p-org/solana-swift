//
//  SerumSwapSwapTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 16/08/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import RxBlocking
@testable import SolanaSwift

class SerumSwapSwapTests: SerumSwapTests {
    func testDirectSwap() throws {
        // Swaps SRM -> USDC on the Serum orderbook.
        try swap(fromWallet: srmWallet, toWallet: usdcWallet, amount: 0.1)

        // Swaps USDC -> SRM on the Serum orderbook.
        try swap(fromWallet: usdcWallet, toWallet: srmWallet, amount: 1)
        
//        // USDC -> USDT special case
//        try swap(fromWallet: usdcWallet, toWallet: usdtWallet, amount: 1)
//
//        // USDT -> USDC special case
//        try swap(fromWallet: usdtWallet, toWallet: usdcWallet, amount: 0.1)
    }
    
    func testTransitiveSwap() throws {
        // Swaps ETH -> BTC on the Serum orderbook.
        try swap(fromWallet: ethWallet, toWallet: btcWallet, amount: 0.00005)
    }
    
    // MARK: - Helpers
    func swap(
        fromWallet: SolanaSDK.Wallet,
        toWallet: SolanaSDK.Wallet,
        amount: Double,
        slippage: Double = 0.05
    ) throws {
        
        let request = serumSwap.swap(
            fromWallet: fromWallet,
            toWallet: toWallet,
            amount: amount,
            slippage: slippage
        )
        
        let signersAndInstructions = try request.toBlocking().first()
        let tx = try solanaSDK.serializeTransaction(instructions: signersAndInstructions!.first!.instructions, signers: [solanaSDK.accountStorage.account!] + signersAndInstructions!.first!.signers).toBlocking().first()
        let txID = try solanaSDK.simulateTransaction(transaction: tx!).toBlocking().first()
    }
}
