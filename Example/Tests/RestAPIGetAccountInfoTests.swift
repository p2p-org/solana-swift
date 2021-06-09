//
//  RestAPIGetAccountInfoTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 09/06/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import SolanaSwift

class RestAPIGetAccountInfoTests: RestAPITests {
    
    func testCheckAccountValidation() throws {
        // funding SOL address
        let isValid1 = try solanaSDK.checkAccountValidation(account: "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG").toBlocking().first()
        XCTAssertEqual(isValid1, true)
        
        // no funding SOL address
        let isValid2 = try solanaSDK.checkAccountValidation(account: "HnXJX1Bvps8piQwDYEYC6oea9GEkvQvahvRj3c97X9xr").toBlocking().first()
        XCTAssertEqual(isValid2, false)
        
        // token address
        let isValid3 = try solanaSDK.checkAccountValidation(account: "8J5wZ4Lo7QSwFWwBfWsWUgsbH4Jr44RFsEYj6qFdXYhM").toBlocking().first()
        XCTAssertEqual(isValid3, true)
        
    }

}
