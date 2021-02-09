//
//  ErrorTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 09/02/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import SolanaSwift

class ErrorTests: XCTestCase {

    func testErrorDescription() throws {
        let error = SolanaSDK.Error.other("Invalid error")
        XCTAssertEqual(error.errorDescription, "Invalid error")
    }

}
