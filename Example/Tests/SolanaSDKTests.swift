//
//  SolanaSDKTests.swift
//  p2p_walletTests
//
//  Created by Chung Tran on 10/28/20.
//

import XCTest
import SolanaSwift

class SolanaSDKTests: XCTestCase {

    var solanaSDK: SolanaSDK!
    var account: String!

    override func setUpWithError() throws {
        solanaSDK = SolanaSDK(accountStorage: InMemoryAccountStorage())
        let account = try SolanaSDK.Account(phrase: InMemoryAccountStorage.accountPhraseToTest.components(separatedBy: " "))
        try solanaSDK.accountStorage.save(account)
        self.account = solanaSDK.accountStorage.account!.publicKey.base58EncodedString
    }

}
