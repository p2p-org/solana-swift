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
    // MARK: - Create and close
    func testCreateTokenAccount() throws {
        // USDC
        let mintAddress = "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v"
        
        _ = try solanaSDK.createTokenAccount(
            mintAddress: mintAddress,
            isSimulation: true
        ).toBlocking().first()
    }
    
    func testCloseAccount() throws {
        let token = "AWgmNoaiXh2GuKQa89dpqE6k23ae4uTmF9ym6USRhVWB"
        
        _ = try solanaSDK.closeTokenAccount(
            tokenPubkey: token,
            isSimulation: true
        ).toBlocking().first()
    }
    
    // MARK: - Send
    func testSendSOL() throws {
        let toPublicKey = "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"
        
        let balance = try solanaSDK.getBalance().toBlocking().first()
        XCTAssertNotNil(balance)
        
        _ = try solanaSDK.sendNativeSOL(
            to: toPublicKey,
            amount: balance!/10,
            isSimulation: true
        ).toBlocking().first()
    }
    
    func testSendSPLToken() throws {
        // USDC
        let mintAddress = "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v"
        let source = "DjY1uZozQTPz9c6WsjpPC3jXWp7u98KzyuyQTRzcGHFk"
        let destination = "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"
        
        _ = try solanaSDK.sendSPLTokens(
            mintAddress: mintAddress,
            decimals: 6,
            from: source,
            to: destination,
            amount: Double(0.001).toLamport(decimals: 6),
            isSimulation: true
        ).toBlocking().first()
    }
}

