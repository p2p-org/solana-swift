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
    func testDecodingDevnetTokens() throws {
        let tokens = SolanaSDK.Token.getSupportedTokens(network: "devnet")
        XCTAssertEqual(tokens?.count, 10)
        XCTAssertEqual(tokens?.first!.mintAddress, "96oUA9Zu6hdpp9rv41b8Z6DqRyVQm1VMqVU4cBxQupNJ")
    }
    
    func testDecodingMainnetBetaTokens() throws {
        let tokens = SolanaSDK.Token.getSupportedTokens(network: "mainnet-beta")
        XCTAssertEqual(tokens?.count, 25)
        XCTAssertEqual(tokens?.first!.mintAddress, "SRMuApVNdxXokk5GT7XD5cUUgXMBCoAz2LHeuAoKWRt")
    }

    func testDecodingProgramAccountFromBase64() throws {
        let string = #"{"account":{"data":["eFnw9lVnndMN5Jzwx+Sz868QyrMH/D9UqaOcluHkD19Q2GYJMr1ICu1igql4jNhnTngax15GTVqOAfyEWk/shOgDAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA","base64"],"executable":false,"lamports":2039280,"owner":"TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA","rentEpoch":35},"pubkey":"94s94H8HNCSxvuduxuG16VybBp1YCpzxMV8x5o7RbPMT"}"#
        let programAccount = try JSONDecoder().decode(SolanaSDK.ProgramAccount<SolanaSDK.AccountInfo>.self, from: string.data(using: .utf8)!)
        let token = SolanaSDK.Token(accountInfo: programAccount.account.data.value!, pubkey: programAccount.pubkey, in: "devnet")
        XCTAssertEqual(token?.amount, 1000)
        XCTAssertEqual(token?.mintAddress, "96oUA9Zu6hdpp9rv41b8Z6DqRyVQm1VMqVU4cBxQupNJ")
    }
    
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
    
    func testDecodingDecimalFromMintLayout() throws {
        let string = #"["AQAAAAYa2dBThxVIU37ePiYYSaPft/0C+rx1siPI5GrbhT0MABCl1OgAAAAGAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA==","base64"]"#
        let mintLayout = try JSONDecoder().decode(SolanaSDK.Buffer<SolanaSDK.Mint>.self, from: string.data(using: .utf8)!).value
        XCTAssertEqual("QqCCvshxtqMAL2CVALqiJB7uEeE5mjSPsseQdDzsRUo", mintLayout?.mintAuthority?.base58EncodedString)
        XCTAssertEqual(1000000000000, mintLayout?.supply)
        XCTAssertEqual(mintLayout?.decimals, 6)
        XCTAssertTrue(mintLayout?.isInitialized == true)
        XCTAssertNil(mintLayout?.freezeAuthority)
    }
}
