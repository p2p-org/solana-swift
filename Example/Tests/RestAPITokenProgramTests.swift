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

class RestAPITokenProgramTests: RestAPITests {
    func testGetTokensInfo() throws {
        let result = try solanaSDK.getTokensInfo(account: "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG").toBlocking().first()
        if result?.count == 0 {
            return
        }
        XCTAssertEqual(result?.first!.mintAddress, "6Xd5kaN87U1CRmJH9r8BTdB91CBEGPkmCjNtn1HiGPcU")
        XCTAssertEqual(result?.first!.pubkey, "sKu9wC5Y2SyRPMyrGdFHAtnKNiaVSsRXRwSnPBszrwE")
        XCTAssertEqual(result?.first!.decimals, 2)
    }
}
