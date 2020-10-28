//
//  SendTransactionTests.swift
//  p2p_walletTests
//
//  Created by Chung Tran on 10/28/20.
//

import XCTest
import SolanaSwift

class SendTransactionTests: SolanaSDKTests {
    
    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        
    }
    
    func testGetBalance() throws {
        let balance = try solanaSDK.getBalance(account: account, commitment: "recent").toBlocking().first()
        XCTAssertNotEqual(balance, 0)
    }

    func testSendingTransaction() throws {
        
    }
}
