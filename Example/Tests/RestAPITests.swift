//
//  DevnetRestAPITests.swift
//  p2p_walletTests
//
//  Created by Chung Tran on 10/28/20.
//

import XCTest
import SolanaSwift

class RestAPITests: XCTestCase {
    var network: String {"devnet"}

    var solanaSDK: SolanaSDK!
    var account: SolanaSDK.Account {solanaSDK.accountStorage.account!}

    override func setUpWithError() throws {
        var endpoint = "https://devnet.solana.com"
        if network == "mainnet-beta" {
            endpoint = "https://api.mainnet-beta.solana.com"
        }
        solanaSDK = SolanaSDK(endpoint: endpoint, accountStorage: InMemoryAccountStorage())
        var phrases = InMemoryAccountStorage.devnetAccount
        if phrases == "mainnet-beta" {
            phrases = InMemoryAccountStorage.mainnetAccount
        }
        let account = try SolanaSDK.Account(phrase: phrases.components(separatedBy: " "), network: network)
        try solanaSDK.accountStorage.save(account)
    }

}
