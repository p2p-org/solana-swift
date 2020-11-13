//
//  TokensTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 13/11/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
import SolanaSwift

class TokensTests: XCTestCase {

    func testDecodingDevnetTokens() throws {
        let tokens = try SolanaSDK.Token.getSupportedTokens(cluster: "devnet")
        XCTAssertEqual(tokens.count, 1)
        XCTAssertEqual(tokens.first!.mintAddress, "96oUA9Zu6hdpp9rv41b8Z6DqRyVQm1VMqVU4cBxQupNJ")
    }
    
    func testDecodingMainnetBetaTokens() throws {
        let tokens = try SolanaSDK.Token.getSupportedTokens(cluster: "mainnet-beta")
        XCTAssertEqual(tokens.count, 25)
        XCTAssertEqual(tokens.first!.mintAddress, "SRMuApVNdxXokk5GT7XD5cUUgXMBCoAz2LHeuAoKWRt")
    }

}
