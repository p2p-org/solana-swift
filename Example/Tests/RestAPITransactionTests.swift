//
//  RestAPITransactionTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 11/9/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import XCTest
import SolanaSwift

class RestAPITransactionTests: RestAPITests {
    override var network: SolanaSDK.Network {.mainnetBeta}
    
//    func testSendTransaction() throws {
//        let accountToSend = try SolanaSDK.PublicKey(string: "GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5")
//        let recentBlockhash = "H8GCAE8Xh72WkGpsgdEhUpwnAHe3eicTW7sHpAQsMg5M"
//        
//        let serializedTransaction = try solanaSDK.createSendTransaction(from: account.publicKey, to: accountToSend, amount: 30, signer: account, recentBlockhash: recentBlockhash)
//            .toBlocking()
//            .first()
//        
//        XCTAssertEqual(serializedTransaction, "AULA0Ln8rBwZkbOGgNxc+Im9neGAHFmI4biKlXKYN89jB49MTPEemz56YGbh4j6rZ8Mr/b0TOK5xbef21aJkmwoBAAEDuWgfemPr3CHjPvuwyKFxgYyk0e6VEqxd/mXKRTUn2cDrerzQ2HXrwm2hsYGjM5s+8qMWlbt6vbxngnO8rc3lqgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA75c8DbV0zMomt13VOkDhzBRQs1g1sjlLlmVUTgygVNgBAgIAAQwCAAAAHgAAAAAAAAA=")
//    }
    
//    func testSwapTransaction() throws {
//        let fromToken = try SolanaSDK.PublicKey(string: "3sRavwSu5dmCjXnu66Y1Phe93MXwUC1Q8Kqi2eh9dWnL") // SOL
//        let toToken = try SolanaSDK.PublicKey(string: "5t9sxN488df2SbCJen3YBV3koLfPJSkdhbGBEK8MSZXo") // USDC
//        let recentBlockhash = "GL7QhRzn39oFsEX2aLmcJRDJKxCRjFUXx9fbiUSPGgn"
//
//        let serializedTransaction = try solanaSDK.createSwapTransaction(owner: account, fromToken: fromToken, toToken: toToken, slippage: 0.01, amount: 1000000, network: network, recentBlockhash: recentBlockhash)
//            .toBlocking()
//            .first()
//        
//        XCTAssertEqual(serializedTransaction, "<Как?>")
//    }
}

