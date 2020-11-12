//
//  ProgramAccountTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 11/12/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
import SolanaSwift

class ProgramAccountTests: XCTestCase {

    func testDecodingProgramAccount() throws {
        let string = #"{"account":{"data":["eFnw9lVnndMN5Jzwx+Sz868QyrMH/D9UqaOcluHkD19Q2GYJMr1ICu1igql4jNhnTngax15GTVqOAfyEWk/shOgDAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA","base64"],"executable":false,"lamports":2039280,"owner":"TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA","rentEpoch":35},"pubkey":"94s94H8HNCSxvuduxuG16VybBp1YCpzxMV8x5o7RbPMT"}"#
        let programAccount = try JSONDecoder().decode(SolanaSDK.ProgramAccount.self, from: string.data(using: .utf8)!)
        XCTAssertEqual(programAccount.account.data.amount, 1000)
        XCTAssertEqual(programAccount.account.data.mint.base58EncodedString, "96oUA9Zu6hdpp9rv41b8Z6DqRyVQm1VMqVU4cBxQupNJ")
        XCTAssertEqual(programAccount.account.data.owner.base58EncodedString, "6SazzPuqoXovicxirySZn6Rq25EvRJwSuoGCdKwdzEQK")
    }
}
