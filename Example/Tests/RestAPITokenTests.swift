//
//  RestAPITokenTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 21/01/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest

class RestAPITokenTests: RestAPITests {
    func testGetTokenAccountBalance() throws {
        let balance = try solanaSDK.getTokenAccountBalance(pubkey: "1dmDx6xPCaHE3wBTyGLASy3BHuvNVFiVBvrtg4X9sxa").toBlocking().first()
        XCTAssertNotNil(balance?.uiAmount)
        XCTAssertNotNil(balance?.amount)
        XCTAssertNotNil(balance?.decimals)
    }
}
