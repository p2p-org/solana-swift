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
    
    func testCreateAToken() throws {
        // USDC
        let mintAddress = "xxxxa1sKNGwFtw2kFn8XauW9xq8hBZ5kVtcSesTT9fW"
        
        _ = try solanaSDK.createAssociatedTokenAccount(
            for: account.publicKey,
            tokenMint: try SolanaSDK.PublicKey(string: mintAddress),
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
        
        // calculate fees
        let preparedTransaction = try solanaSDK.prepareSendingNativeSOL(
            to: toPublicKey,
            amount: balance!/10
        ).toBlocking().first()!
        
        XCTAssertEqual(preparedTransaction.expectedFee, .init(transaction: 5000, accountBalances: 0))
        
        // send simulation
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
        
        // calculate fees
        let preparedTransaction = try solanaSDK.prepareSendingSPLTokens(
            mintAddress: mintAddress,
            decimals: 6,
            from: source,
            to: destination,
            amount: Double(0.001).toLamport(decimals: 6),
            feePayer: "B4PdyoVU39hoCaiTLPtN9nJxy6rEpbciE3BNPvHkCeE2"
        ).toBlocking().first()!.preparedTransaction
        
        XCTAssertEqual(preparedTransaction.expectedFee, .init(transaction: 10000, accountBalances: 2039280))
        
        // send simulation
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

