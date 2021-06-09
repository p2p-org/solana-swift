//
//  DevnetRestAPITests.swift
//  p2p_walletTests
//
//  Created by Chung Tran on 10/28/20.
//

import XCTest
import SolanaSwift

class RestAPITests: XCTestCase {
    var endpoint: SolanaSDK.APIEndPoint {
        .init(
            url: "https://api.mainnet-beta.solana.com",
            network: .mainnetBeta
        )
    }
    var solanaSDK: SolanaSDK!
    var account: SolanaSDK.Account {solanaSDK.accountStorage.account!}

    override func setUpWithError() throws {
        let accountStorage = InMemoryAccountStorage()
        solanaSDK = SolanaSDK(endpoint: endpoint, accountStorage: accountStorage)
        let account = try SolanaSDK.Account(phrase: endpoint.network.testAccount.components(separatedBy: " "), network: endpoint.network)
        try accountStorage.save(account)
    }
    
    func testGetTokenAccountBalance() throws {
        let balance = try solanaSDK.getTokenAccountBalance(pubkey: "1dmDx6xPCaHE3wBTyGLASy3BHuvNVFiVBvrtg4X9sxa").toBlocking().first()
        XCTAssertNotNil(balance?.uiAmount)
        XCTAssertNotNil(balance?.amount)
        XCTAssertNotNil(balance?.decimals)
    }

}
