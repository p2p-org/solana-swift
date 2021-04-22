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
    var list: [SolanaSDK.Token]!

    override func setUpWithError() throws {
        parser = SolanaSDK.TokensListParser()
        list = try parser.parse(network: SolanaSDK.Network.mainnetBeta.cluster)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testParsing() throws {
        // List count must be equal to 396 after removing duppicated items
        XCTAssertEqual(list.count, 396)
        
        // Tags must be parsed
        XCTAssertEqual(list[2].tags.count, 2)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

