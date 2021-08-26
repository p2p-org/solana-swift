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
    override var overridingAccount: String? {
        "oval you token plug copper visa employ link sell asset kick sausage"
    }
    
    func testDirectSwap() throws {
        var pointer = 0
        let number = try UInt64(buffer: Data([UInt8]([109,31,0,0,0,0,0,0])), pointer: &pointer)
        
        // Swaps SRM -> USDC on the Serum orderbook.
        let market = SRMUSDCMarket
        let request = serumSwap.swap(
            .init(
                fromMint: SRM,
                toMint: USDC,
                quoteMint: nil,
                amount: 8046,
                minExchangeRate: .init(
                    rate: 8045,
                    fromDecimals: SRMDecimals,
                    quoteDecimals: USDCDecimals,
                    strict: false
                ),
                referral: nil,
                fromWallet: "FhLHuY5iREGpp2ft5w7gNfbxYWmjWzGuRs14P2bdZzde",
                toWallet: "8TnZDzWSzkSrRVxwGY6uPTaPSt2NDBvKD6uA5SZD3P87",
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
