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
    override var overridingAccount: String? {
        "oval you token plug copper visa employ link sell asset kick sausage"
    }
    
    func testDirectSwap() throws {
        // Swaps SRM -> USDC on the Serum orderbook.
        try directSwap(reversed: false, amount: 0.1)
        
        // Swaps USDC -> SRM on the Serum orderbook.
        try directSwap(reversed: true, amount: 1)
    }
    
    func testTransitiveSwap() throws {
        // Swaps ETH -> BTC on the Serum orderbook.
        let fromMint    = ETH
        let toMint      = BTC
        let fromDecimal = ETHDecimals
        let toDecimal   = BTCDecimals
        
        let amount: Double = 0.00005
        let slippage = 0.05 // 5%
        
        // Load market, fair and exchange rate
        let markets = try serumSwap.loadMarket(fromMint: fromMint, toMint: toMint).toBlocking().first()
        let fromMarket = markets!.first!
        let toMarket = markets!.last!
        let fair = try serumSwap.loadFair(fromMint: fromMint, toMint: toMint, markets: markets).toBlocking().first()
        let exchangeRate = serumSwap.calculateExchangeRate(
            fair: fair!,
            slippage: slippage,
            fromDecimals: fromDecimal,
            toDecimal: toDecimal,
            strict: false
        )
        
        let request = serumSwap.swap(
            .init(
                fromMint: fromMint,
                toMint: toMint,
                quoteMint: <#T##SerumSwap.PublicKey?#>,
                amount: amount.toLamport(decimals: fromDecimal),
                minExchangeRate: exchangeRate,
                referral: nil,
                fromWallet: "4ELaJvAe18EX4vb3wddGtveQuSMLw599t7Syc3L3wYsf",
                toWallet: <#T##SerumSwap.PublicKey?#>,
                quoteWallet: <#T##SerumSwap.PublicKey?#>,
                fromMarket: fromMarket,
                toMarket: toMarket,
                fromOpenOrders: nil,
                toOpenOrders: nil,
                close: true
            )
        )
    }
    
    // MARK: - Helpers
    func directSwap(reversed: Bool, amount: Double) throws {
        let fromMint        = reversed ? USDC: SRM
        let toMint          = reversed ? SRM: USDC
        let fromDecimal     = reversed ? USDCDecimals: SRMDecimals
        let toDecimal       = reversed ? SRMDecimals: USDCDecimals
        var fromWallet: SolanaSDK.PublicKey = "FhLHuY5iREGpp2ft5w7gNfbxYWmjWzGuRs14P2bdZzde"
        var toWallet: SolanaSDK.PublicKey = "8TnZDzWSzkSrRVxwGY6uPTaPSt2NDBvKD6uA5SZD3P87"
        
        if reversed {
            swap(&fromWallet, &toWallet)
        }
        // Input
        let slippage = 0.005 // 0.5 %
        
        // Load market, fair and exchange rate
        let markets = try serumSwap.loadMarket(fromMint: fromMint, toMint: toMint).toBlocking().first()
        let fair = try serumSwap.loadFair(fromMint: fromMint, toMint: toMint, markets: markets).toBlocking().first()
        let exchangeRate = serumSwap.calculateExchangeRate(
            fair: fair!,
            slippage: slippage,
            fromDecimals: fromDecimal,
            toDecimal: toDecimal,
            strict: false
        )
        
        let request = serumSwap.swap(
            .init(
                fromMint: fromMint,
                toMint: toMint,
                quoteMint: nil,
                amount: amount.toLamport(decimals: fromDecimal),
                minExchangeRate: exchangeRate,
                referral: nil,
                fromWallet: fromWallet,
                toWallet: toWallet,
                quoteWallet: nil,
                fromMarket: markets!.first!,
                toMarket: nil,
                fromOpenOrders: nil,
                toOpenOrders: nil,
                close: true
            )
        )
        let signersAndInstructions = try request.toBlocking().first()
        let tx = try solanaSDK.serializeTransaction(instructions: signersAndInstructions!.first!.instructions, signers: [solanaSDK.accountStorage.account!] + signersAndInstructions!.first!.signers).toBlocking().first()
        let txID = try solanaSDK.simulateTransaction(transaction: tx!).toBlocking().first()
    }
}
