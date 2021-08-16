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
        serumSwap = .init(client: solanaSDK, accountProvider: solanaSDK)
    }

    func testDirectSwap() throws {
        let request = serumSwap.swap(
            .init(
                fromMint: "Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB",
                toMint: "SRMuApVNdxXokk5GT7XD5cUUgXMBCoAz2LHeuAoKWRt",
                amount: 1000,
                referral: nil,
                quoteWallet: nil,
                fromWallet: "F7jFFtqursGMQH5MoPPRxFzJMwr4cm7peiCBX4PvuRkL",
                toWallet: "4cmcbL49XE5YEQGp4d6DRsNB9EjHrUrQbk4zZhGTy9tE",
                feePayer: nil
            )
        )
        
        let result = try request.toBlocking().first()
        
        
    }
    
    func testTransitiveSwap() throws {
        
    }

}
