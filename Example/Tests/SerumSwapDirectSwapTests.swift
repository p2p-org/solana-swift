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

class SerumSwapDirectSwapTests: SerumSwapTests {
    func testDirectSwap() throws {
        // Swaps SRM -> USDC on the Serum orderbook.
        let market = SRMUSDCMarket
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
        let tx = try solanaSDK.serializeTransaction(instructions: signersAndInstructions!.first!.instructions, signers: [solanaSDK.accountStorage.account!] + signersAndInstructions!.first!.signers).toBlocking().first()
        let txID = try solanaSDK.simulateTransaction(transaction: tx!).toBlocking().first()
    }
}
