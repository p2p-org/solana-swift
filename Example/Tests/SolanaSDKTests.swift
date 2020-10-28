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
        try solanaSDK.createOrRestoreAccount(phrase: InMemoryAccountStorage.accountPhraseToTest)
        account = solanaSDK.accountStorage.account!.publicKey.base58EncodedString
    }

}
