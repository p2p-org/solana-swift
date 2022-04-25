//
//  SolanaTokensListParserTests.swift
//  solana-token-list-swift_Tests
//
//  Created by Chung Tran on 21/04/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import SolanaSwift

class SolanaTokensListParserTests: XCTestCase {
    var parser: SolanaSDK.TokensListParser!

    override func setUpWithError() throws {
        parser = SolanaSDK.TokensListParser()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testParsing() throws {
        // List count must be equal to 396 after removing duppicated items
        let list = try parser.parse(network: "mainnet-beta").toBlocking().first()
        XCTAssertNotEqual(list?.count, 0)
        
        // Tags must be parsed
        XCTAssertEqual(list?[2].tags.count, 1)
    }
}

