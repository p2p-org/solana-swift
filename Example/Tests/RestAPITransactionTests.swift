//
//  RestAPITransactionTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 11/9/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import XCTest
import SolanaSwift

class RestAPITransactionTests: RestAPITests {
    let accountToSend = "GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5"
    
    func testSendToken() throws {
        XCTAssertNoThrow(try solanaSDK.send(to: accountToSend, amount: 30).toBlocking().first())
    }
}
