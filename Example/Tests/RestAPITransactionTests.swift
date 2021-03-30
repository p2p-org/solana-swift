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
        let token = "BdbcJv1RTrbybDK4VkxoSNSSdnWgzi4GNo2WhEAeUai5"
        
        _ = try solanaSDK.closeTokenAccount(
            tokenPubkey: token,
            isSimulation: true
        ).toBlocking().first()
    }
    
    // MARK: - Send
    func testSendSOL() throws {
        let toPublicKey = "F5Ju1iFZ8yf1iTB1YcHVG23rcgm2ubBtiL6nZSyVvnEW"
        
        let balance = try solanaSDK.getBalance().toBlocking().first()
        XCTAssertNotNil(balance)
        
        _ = try solanaSDK.sendSOL(
            to: toPublicKey,
            amount: balance!/2,
            isSimulation: true
        ).toBlocking().first()
    }
    
    func testSendSPLToken() throws {
        // USDC
        let mintAddress = "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v"
        let source = "Wb9uEKqNcmSQh1WRnt1tYWyfKL8iPpr7fxbNzRTYvXA"
        let destination = "6MZ96bCAWsNRKSLGFpFiQNVQamtMTiayRgv7c2vGRSJh"
        
        _ = try solanaSDK.sendSPLTokens(
            mintAddress: mintAddress,
            from: source,
            to: destination,
            amount: Double(0.05).toLamport(decimals: 6),
            isSimulation: true
        ).toBlocking().first()
    }
}

