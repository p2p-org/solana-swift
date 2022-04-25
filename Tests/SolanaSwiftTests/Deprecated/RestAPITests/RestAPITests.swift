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
            address: "https://api.mainnet-beta.solana.com",
            network: .mainnetBeta
        )
    }
    var solanaSDK: SolanaSDK!
    var account: SolanaSDK.Account {solanaSDK.accountStorage.account!}
    
    var overridingAccount: String? {
        nil
    }

    override func setUpWithError() throws {
        let accountStorage = InMemoryAccountStorage()
        solanaSDK = SolanaSDK(endpoint: endpoint, accountStorage: accountStorage)
        let account = try SolanaSDK.Account(phrase: (overridingAccount ?? endpoint.network.testAccount).components(separatedBy: " "), network: endpoint.network)
        try accountStorage.save(account)
    }
}
