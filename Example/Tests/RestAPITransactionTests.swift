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
        let token = "4RFq2wRmzWoJBuwCSs3k2LUVzbaePsZmZ3qp7AovtYRr"
        
        _ = try solanaSDK.closeTokenAccount(
            tokenPubkey: token,
            isSimulation: false
        ).toBlocking().first()
    }
    
    // MARK: - Send
    func testSendSOL() throws {
        let toPublicKey = "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"
        
        let balance = try solanaSDK.getBalance().toBlocking().first()
        XCTAssertNotNil(balance)
        
        _ = try solanaSDK.sendSOL(
            to: toPublicKey,
            amount: balance!/10,
            isSimulation: false
        ).toBlocking().first()
    }
    
    func testSendSPLToken() throws {
        // USDC
        let mintAddress = "BXXkv6z8ykpG1yuvUDPgh732wzVHB69RnB9YgSYh3itW"
        let source = "7EAxe1FCinZJU6RjPJVTmTgXAbDceFhsCe3Gg1nRZZjn"
        let destination = "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"
        
        _ = try solanaSDK.sendSPLTokens(
            mintAddress: mintAddress,
            from: source,
            to: destination,
            amount: Double(0.001466).toLamport(decimals: 6),
            isSimulation: false
        ).toBlocking().first()
    }
    
    func testSwapToken() throws {
        let source = try SolanaSDK.PublicKey(string: "6QuXb6mB6WmRASP2y8AavXh6aabBXEH5ZzrSH5xRrgSm")
        let sourceMint = SolanaSDK.PublicKey.wrappedSOLMint
        let destinationMint = try SolanaSDK.PublicKey(string: "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v")
        
        _ = try solanaSDK.swap(
            source: source,
            sourceMint: sourceMint,
            destinationMint: destinationMint,
            slippage: 0.5,
            amount: 0.001.toLamport(decimals: 9),
            isSimulation: true
        ).toBlocking().first()
    }
}

