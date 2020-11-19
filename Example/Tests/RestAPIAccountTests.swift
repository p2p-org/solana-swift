//
//  SolanaSwiftSDKTests.swift
//  p2p_walletTests
//
//  Created by Chung Tran on 10/26/20.
//

import XCTest
import SolanaSwift
import RxBlocking
import RxSwift

class RestAPIAccountTests: RestAPITests {
    func testGetBalance() throws {
        let balance = try solanaSDK.getBalance(account: account, commitment: "recent").toBlocking().first()
        XCTAssertNotEqual(balance, 0)
    }
    
    func testRequestAirDrop() throws {
        let balance = try solanaSDK.requestAirdrop(account: account, lamports: 89588000)
            .flatMap{_ in Single<Int>.timer(.seconds(10), scheduler: MainScheduler.instance)}
            .flatMap{_ in self.solanaSDK.getBalance(account: self.account, commitment: "recent")}
            .toBlocking().first()
        XCTAssertNotEqual(balance, 0)
    }
}
