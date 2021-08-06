//
//  DecodingTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 11/12/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
import SolanaSwift

class DecodingTests: XCTestCase {
    
//    func testDecodingProgramAccountFromParsedJSON() throws {
//        let string = #"{"account":{"data":{"parsed":{"info":{"isNative":false,"mint":"2tQ2LU4Rw48fEGZpJMKxpDbY7UgFaK2rRYb8sn2WbbYY","owner":"6SazzPuqoXovicxirySZn6Rq25EvRJwSuoGCdKwdzEQK","state":"initialized","tokenAmount":{"amount":"1000","decimals":2,"uiAmount":10}},"type":"account"},"program":"spl-token","space":165},"executable":false,"lamports":2039280,"owner":"TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA","rentEpoch":39},"pubkey":"Ho4gEVDQpUtpMAMB1yzMSY4QD1hXAmzokHKjFBE9cZAu"}"#
//        let programAccount = try JSONDecoder().decode(SolanaSDK.ProgramAccount<SolanaSDK.AccountInfo>.self, from: string.data(using: .utf8)!)
//        let token = SolanaSDK.Token(accountInfo: programAccount.account.data.value!, pubkey: programAccount.pubkey, in: "devnet")
//        XCTAssertEqual(token?.pubkey, "Ho4gEVDQpUtpMAMB1yzMSY4QD1hXAmzokHKjFBE9cZAu")
//        XCTAssertEqual(token?.mintAddress, "2tQ2LU4Rw48fEGZpJMKxpDbY7UgFaK2rRYb8sn2WbbYY")
////        XCTAssertEqual(token?.owner, "6SazzPuqoXovicxirySZn6Rq25EvRJwSuoGCdKwdzEQK")
//        XCTAssertEqual(token?.decimals, 2)
//        XCTAssertEqual(token?.amount, 1000)
//    }
}
