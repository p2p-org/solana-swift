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
        
        let solanaSDK = SolanaSDK(
            endpoint: endpoint,
            accountStorage: InMemoryAccountStorage()
        )
        let account = try SolanaSDK.Account(phrase: endpoint.network.testAccount.components(separatedBy: " "), network: endpoint.network)
        try solanaSDK.accountStorage.save(account)
        
        feeRelayer = SolanaSDK.FeeRelayer(solanaAPIClient: solanaSDK)
    }
    
    func testGetFeePayerPubkey() throws {
        let _ = try feeRelayer.getFeePayerPubkey().toBlocking().first()
    }
}
