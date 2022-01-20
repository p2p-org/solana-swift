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
    func testSendNativeSOL() throws {
        let toPublicKey = "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"
        
        let balance = try solanaSDK.getBalance().toBlocking().first()
        XCTAssertNotNil(balance)
        
        var transaction = try solanaSDK.createSendNativeSOLTransaction(
            to: toPublicKey,
            amount: balance!/10
        ).toBlocking().first()!
        
        let serializedTransaction = try transaction.serialize().bytes.toBase64()
        
        let _ = try solanaSDK.simulateTransaction(
            transaction: serializedTransaction
        ).toBlocking().first()!
    }
    
    func testSendSPLToken() throws {
        // USDC
        let mintAddress = "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v"
        let source = "DjY1uZozQTPz9c6WsjpPC3jXWp7u98KzyuyQTRzcGHFk"
        let destination = "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"
        
        let preparedParams = try solanaSDK.createSendSPLTokensTransaction(
            mintAddress: mintAddress,
            decimals: 6,
            from: source,
            to: destination,
            amount: Double(0.001).toLamport(decimals: 6)
        ).toBlocking().first()!
        
        let realDestination = preparedParams.realDestination
        XCTAssertEqual(realDestination, "3uetDDizgTtadDHZzyy9BqxrjQcozMEkxzbKhfZF4tG3")
        
        var transaction = preparedParams.transaction
        let serializedTransaction = try transaction.serialize().bytes.toBase64()
        
        let _ = try solanaSDK.simulateTransaction(
            transaction: serializedTransaction
        ).toBlocking().first()!
    }
}

