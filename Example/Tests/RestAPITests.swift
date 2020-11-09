//
//  RestAPITests.swift
//  p2p_walletTests
//
//  Created by Chung Tran on 10/28/20.
//

import XCTest
import SolanaSwift

class RestAPITests: XCTestCase {

    var solanaSDK: SolanaSDK!
    var account: String!

    override func setUpWithError() throws {
        solanaSDK = SolanaSDK(endpoint: "https://testnet.solana.com", accountStorage: InMemoryAccountStorage())
        let account = try SolanaSDK.Account(phrase: InMemoryAccountStorage.accountPhraseToTest.components(separatedBy: " "))
        try solanaSDK.accountStorage.save(account)
        self.account = solanaSDK.accountStorage.account!.publicKey.base58EncodedString
    }

}
