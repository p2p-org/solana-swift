//
//  DevnetRestAPITests.swift
//  p2p_walletTests
//
//  Created by Chung Tran on 10/28/20.
//

import XCTest
import SolanaSwift

class RestAPITests: XCTestCase {
    var network: SolanaSDK.Network {.devnet}
    var solanaSDK: SolanaSDK!
    var account: SolanaSDK.Account {solanaSDK.accountStorage.account!}

    override func setUpWithError() throws {
        solanaSDK = SolanaSDK(network: network, accountStorage: InMemoryAccountStorage())
        let account = try SolanaSDK.Account(phrase: network.testAccount.components(separatedBy: " "), network: network)
        try solanaSDK.accountStorage.save(account)
    }

}
