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
    
    func testDecodingMint() throws {
        let string = #"["AQAAAAYa2dBThxVIU37ePiYYSaPft/0C+rx1siPI5GrbhT0MABCl1OgAAAAGAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA==","base64"]"#
        let mintLayout = try JSONDecoder().decode(SolanaSDK.Buffer<SolanaSDK.Mint>.self, from: string.data(using: .utf8)!).value
        
        XCTAssertEqual(mintLayout?.mintAuthorityOption, 1)
        XCTAssertEqual(mintLayout?.mintAuthority?.base58EncodedString, "QqCCvshxtqMAL2CVALqiJB7uEeE5mjSPsseQdDzsRUo")
        XCTAssertEqual(mintLayout?.supply, 1000000000000)
        XCTAssertEqual(mintLayout?.decimals, 6)
        XCTAssertEqual(mintLayout?.isInitialized, true)
        XCTAssertEqual(mintLayout?.freezeAuthorityOption, 0)
        XCTAssertNil(mintLayout?.freezeAuthority)
    }
    
    func testDecodingAccountInfo() throws {
        let string = #"["BhrZ0FOHFUhTft4+JhhJo9+3/QL6vHWyI8jkatuFPQwCqmOzhzy1ve5l2AqL0ottCChJZ1XSIW3k3C7TaBQn7aCGAQAAAAAAAQAAAOt6vNDYdevCbaGxgaMzmz7yoxaVu3q9vGeCc7ytzeWqAQAAAAAAAAAAAAAAAGQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA","base64"]"#
        let accountInfo = try JSONDecoder().decode(SolanaSDK.Buffer<SolanaSDK.AccountInfo>.self, from: string.data(using: .utf8)!).value
        
        XCTAssertEqual("QqCCvshxtqMAL2CVALqiJB7uEeE5mjSPsseQdDzsRUo", accountInfo?.mint.base58EncodedString)
        XCTAssertEqual("BQWWFhzBdw2vKKBUX17NHeFbCoFQHfRARpdztPE2tDJ", accountInfo?.owner.base58EncodedString)
        XCTAssertEqual(accountInfo?.lamports, 100000)
        XCTAssertEqual(accountInfo?.delegateOption, 1)
        XCTAssertEqual("GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5", accountInfo?.delegate?.base58EncodedString)
        XCTAssertEqual(accountInfo?.isInitialized, true)
        XCTAssertEqual(accountInfo?.isFrozen, false)
        XCTAssertEqual(accountInfo?.state, 1)
        XCTAssertEqual(accountInfo?.isNativeOption, 0)
        XCTAssertEqual(accountInfo?.rentExemptReserve, nil)
        XCTAssertEqual(accountInfo?.isNativeRaw, 0)
        XCTAssertEqual(accountInfo?.isNative, false)
        XCTAssertEqual(accountInfo?.delegatedAmount, 100)
        XCTAssertEqual(accountInfo?.closeAuthorityOption, 0)
        XCTAssertEqual(accountInfo?.closeAuthority?.base58EncodedString, nil)
    }
    
    func testDecodingAccountInfo2() throws {
        let string = #"["AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAOt6vNDYdevCbaGxgaMzmz7yoxaVu3q9vGeCc7ytzeWq","base64"]"#
        let accountInfo = try JSONDecoder().decode(SolanaSDK.Buffer<SolanaSDK.AccountInfo>.self, from: string.data(using: .utf8)!).value
        
        XCTAssertEqual("11111111111111111111111111111111", accountInfo?.mint.base58EncodedString)
        XCTAssertEqual("11111111111111111111111111111111", accountInfo?.owner.base58EncodedString)
        XCTAssertEqual(accountInfo?.lamports, 0)
        XCTAssertEqual(accountInfo?.delegateOption, 0)
        XCTAssertNil(accountInfo?.delegate)
        XCTAssertEqual(accountInfo?.isInitialized, false)
        XCTAssertEqual(accountInfo?.isFrozen, false)
        XCTAssertEqual(accountInfo?.state, 0)
        XCTAssertEqual(accountInfo?.isNativeOption, 0)
        XCTAssertNil(accountInfo?.rentExemptReserve)
        XCTAssertEqual(accountInfo?.isNativeRaw, 0)
        XCTAssertEqual(accountInfo?.isNative, false)
        XCTAssertEqual(accountInfo?.delegatedAmount, 0)
        XCTAssertEqual(accountInfo?.closeAuthorityOption, 1)
        XCTAssertEqual(accountInfo?.closeAuthority?.base58EncodedString, "GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5")
        
        let string2 = #"["AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAOt6vNDYdevCbaGxgaMzmz7yoxaVu3q9vGeCc7ytzeWq","base64"]"#
        let accountInfo2 = try JSONDecoder().decode(SolanaSDK.Buffer<SolanaSDK.AccountInfo>.self, from: string2.data(using: .utf8)!).value
        
        
        XCTAssertEqual("11111111111111111111111111111111", accountInfo2?.mint.base58EncodedString)
        XCTAssertEqual("11111111111111111111111111111111", accountInfo2?.owner.base58EncodedString)
        XCTAssertEqual(accountInfo2?.lamports, 0)
        XCTAssertEqual(accountInfo2?.delegateOption, 0)
        XCTAssertNil(accountInfo2?.delegate)
        XCTAssertEqual(accountInfo2?.isInitialized, true)
        XCTAssertEqual(accountInfo2?.isFrozen, true)
        XCTAssertEqual(accountInfo2?.state, 2)
        XCTAssertEqual(accountInfo2?.isNativeOption, 0)
        XCTAssertNil(accountInfo2?.rentExemptReserve)
        XCTAssertEqual(accountInfo2?.isNativeRaw, 0)
        XCTAssertEqual(accountInfo2?.isNative, false)
        XCTAssertEqual(accountInfo2?.delegatedAmount, 0)
        XCTAssertEqual(accountInfo2?.closeAuthorityOption, 1)
        XCTAssertEqual(accountInfo2?.closeAuthority?.base58EncodedString, "GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5")
    }
}
