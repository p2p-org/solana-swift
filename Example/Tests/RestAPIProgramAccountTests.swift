//
//  RestAPIProgramAccountTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 11/12/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import XCTest
import SolanaSwift

class RestAPIProgramAccountTests: RestAPITests {
    func testGetProgramAccounts() throws {
        XCTAssertNoThrow(try solanaSDK.getProgramAccounts(account: "6SazzPuqoXovicxirySZn6Rq25EvRJwSuoGCdKwdzEQK", in: "devnet").toBlocking().first())
    }
}
