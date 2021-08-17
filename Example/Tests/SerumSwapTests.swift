//
//  SerumSwapTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 16/08/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import RxBlocking
import SolanaSwift

class SerumSwapTests: RestAPITests {
    override var overridingAccount: String? {
        "miracle pizza supply useful steak border same again youth silver access hundred"
    }
    
    var serumSwap: SerumSwap!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        serumSwap = .init(client: solanaSDK, accountProvider: solanaSDK, tokenListContainer: solanaSDK)
    }

    func testDirectSwap() throws {
        let request = serumSwap.swap(
            .init(
                fromMint: try SolanaSDK.PublicKey(string: "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v"),
                toMint: try SolanaSDK.PublicKey(string: "9n4nbM75f5Ui33ZbPYXn59EwSgE8CGsHtAeTH5YFeJ9E"),
                amount: 1000,
                referral: nil,
                quoteWallet: nil,
                fromWallet: try SolanaSDK.PublicKey(string: "9GQV3bQP9tv7m6XgGMaixxEeEdxtFhwgABw2cxCFZoch"),
                toWallet: nil,
                feePayer: nil
            )
        )
        
        let result = try request.toBlocking().first()
        
        
    }
    
    func testTransitiveSwap() throws {
        
    }

}
