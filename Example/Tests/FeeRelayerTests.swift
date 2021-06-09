//
//  FeeRelayerTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 12/05/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import XCTest
import SolanaSwift
import RxBlocking

class FeeRelayerTests: XCTestCase {
    var feeRelayer: SolanaSDK.FeeRelayer!
    
    override func setUpWithError() throws {
        let endpoint = SolanaSDK.APIEndPoint(
            url: "https://solana-api.projectserum.com",
            network: .mainnetBeta
        )
        
        let accountStorage = InMemoryAccountStorage()
        
        let solanaSDK = SolanaSDK(
            endpoint: endpoint,
            accountStorage: accountStorage
        )
        let account = try SolanaSDK.Account(phrase: endpoint.network.testAccount.components(separatedBy: " "), network: endpoint.network)
        
        try accountStorage.save(account)
        
        feeRelayer = SolanaSDK.FeeRelayer(solanaAPIClient: solanaSDK)
    }
    
    func testGetFeePayerPubkey() throws {
        let _ = try feeRelayer.getFeePayerPubkey().toBlocking().first()
    }
    
    func testSendSOLWithoutFee() throws {
        let transactionId = try feeRelayer.transferSOL(
            to: "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG",
            amount: 0.000955716.toLamport(decimals: 9)
        ).toBlocking().first()
        
        XCTAssertNotNil(transactionId)
    }
    
    func testSendTokenWithoutFee() throws {
        let transactionId = try feeRelayer.transferSPLToken(
            mintAddress: "kinXdEcpDQeHPEuQnqmUgtYykqKGVFq6CeVX5iAHJq6",
            from: "93gmUv69EYA8V2jS8DRYxcpXHdX8bGQgq3Sef5EJMnDV",
            to: "6pTvDGDMqtFZRuqZeLx1ddPW74XZ8Ub18CTvRWqu9VUx",
            amount: 80.78.toLamport(decimals: 5),
            decimals: 5
        ).toBlocking().first()
        
        XCTAssertNotNil(transactionId)
    }
}
