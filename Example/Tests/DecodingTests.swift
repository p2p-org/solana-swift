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
        let tokens = SolanaSDK.Token.getSupportedTokens(network: .devnet)
        XCTAssertEqual(tokens?.count, 10)
        XCTAssertEqual(tokens?.first!.mintAddress, "96oUA9Zu6hdpp9rv41b8Z6DqRyVQm1VMqVU4cBxQupNJ")
    }
    
    func testDecodingMainnetBetaTokens() throws {
        let tokens = SolanaSDK.Token.getSupportedTokens(network: .mainnetBeta)
        XCTAssertEqual(tokens?.count, 25)
        XCTAssertEqual(tokens?.first!.mintAddress, "SRMuApVNdxXokk5GT7XD5cUUgXMBCoAz2LHeuAoKWRt")
    }

    func testDecodingProgramAccountFromBase64() throws {
        let string = #"{"account":{"data":["eFnw9lVnndMN5Jzwx+Sz868QyrMH/D9UqaOcluHkD19Q2GYJMr1ICu1igql4jNhnTngax15GTVqOAfyEWk/shOgDAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA","base64"],"executable":false,"lamports":2039280,"owner":"TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA","rentEpoch":35},"pubkey":"94s94H8HNCSxvuduxuG16VybBp1YCpzxMV8x5o7RbPMT"}"#
        let programAccount = try JSONDecoder().decode(SolanaSDK.ProgramAccount<SolanaSDK.AccountInfo>.self, from: string.data(using: .utf8)!)
        let token = SolanaSDK.Token(accountInfo: programAccount.account.data.value!, pubkey: programAccount.pubkey, in: .devnet)
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
    
    func testDecodingMint() throws {
        let string = #"["AQAAAAYa2dBThxVIU37ePiYYSaPft/0C+rx1siPI5GrbhT0MABCl1OgAAAAGAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA==","base64"]"#
        let mintLayout = try JSONDecoder().decode(SolanaSDK.Buffer<SolanaSDK.Mint>.self, from: string.data(using: .utf8)!).value
        XCTAssertEqual("QqCCvshxtqMAL2CVALqiJB7uEeE5mjSPsseQdDzsRUo", mintLayout?.mintAuthority?.base58EncodedString)
        XCTAssertEqual(1000000000000, mintLayout?.supply)
        XCTAssertEqual(mintLayout?.decimals, 6)
        XCTAssertTrue(mintLayout?.isInitialized == true)
        XCTAssertNil(mintLayout?.freezeAuthority)
    }
    
    func testDecodingAccountInfo() throws {
        let string = #"["BhrZ0FOHFUhTft4+JhhJo9+3/QL6vHWyI8jkatuFPQwCqmOzhzy1ve5l2AqL0ottCChJZ1XSIW3k3C7TaBQn7aCGAQAAAAAAAQAAAOt6vNDYdevCbaGxgaMzmz7yoxaVu3q9vGeCc7ytzeWqAQAAAAAAAAAAAAAAAGQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA","base64"]"#
        let accountInfo = try JSONDecoder().decode(SolanaSDK.Buffer<SolanaSDK.AccountInfo>.self, from: string.data(using: .utf8)!).value
        
        XCTAssertEqual("QqCCvshxtqMAL2CVALqiJB7uEeE5mjSPsseQdDzsRUo", accountInfo?.mint.base58EncodedString)
        XCTAssertEqual("BQWWFhzBdw2vKKBUX17NHeFbCoFQHfRARpdztPE2tDJ", accountInfo?.owner.base58EncodedString)
        XCTAssertEqual("GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5", accountInfo?.delegate?.base58EncodedString)
        XCTAssertEqual(100, accountInfo?.delegatedAmount)
        XCTAssertEqual(false, accountInfo?.isNative)
        XCTAssertEqual(true, accountInfo?.isInitialized)
        XCTAssertEqual(false, accountInfo?.isFrozen)
        XCTAssertNil(accountInfo?.rentExemptReserve)
        XCTAssertNil(accountInfo?.closeAuthority)
    }
    
    func testDecodingAccountInfo2() throws {
        let string = #"["AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAOt6vNDYdevCbaGxgaMzmz7yoxaVu3q9vGeCc7ytzeWq","base64"]"#
        let accountInfo = try JSONDecoder().decode(SolanaSDK.Buffer<SolanaSDK.AccountInfo>.self, from: string.data(using: .utf8)!).value
        
        XCTAssertNil(accountInfo?.delegate)
        XCTAssertEqual(0, accountInfo?.delegatedAmount)
        XCTAssertEqual(false, accountInfo?.isInitialized)
        XCTAssertEqual(false, accountInfo?.isNative)
        XCTAssertNil(accountInfo?.rentExemptReserve)
        XCTAssertEqual("GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5", accountInfo?.closeAuthority?.base58EncodedString)
        
        let string2 = #"["AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAOt6vNDYdevCbaGxgaMzmz7yoxaVu3q9vGeCc7ytzeWq","base64"]"#
        let accountInfo2 = try JSONDecoder().decode(SolanaSDK.Buffer<SolanaSDK.AccountInfo>.self, from: string2.data(using: .utf8)!).value
        
        
        XCTAssertEqual(true, accountInfo2?.isFrozen)
    }
    
    func testDecodingSwapData() throws {
        let string = #"["Af8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAJtI5Id8QBhfDU9HbNjlM8tWzr5NFhnaIL7zaMrcQO6xAAMAAAAAAAAA6AMAAAAAAAABAAAAAAAAAOgDAAAAAAAAAAAAAAAAAAA=", "base64"]"#
        
        let publicKey = try SolanaSDK.PublicKey(string: "11111111111111111111111111111111")
        
        let info = try JSONDecoder().decode(SolanaSDK.Buffer<SolanaSDK.TokenSwapInfo>.self, from: string.data(using: .utf8)!)
        
        XCTAssertTrue(info.value?.isInitialized == true)
        XCTAssertEqual(255, info.value?.nonce)
        XCTAssertEqual(publicKey, info.value?.tokenProgramId)
        XCTAssertEqual(publicKey, info.value?.tokenAccountA)
        XCTAssertEqual(publicKey, info.value?.tokenAccountB)
        XCTAssertEqual(publicKey, info.value?.tokenPool)
        XCTAssertEqual(publicKey, info.value?.mintA)
        XCTAssertEqual(publicKey, info.value?.mintB)
        XCTAssertEqual(publicKey, info.value?.feeAccount)
        XCTAssertEqual(155, info.value?.curveType)
        XCTAssertEqual(963515510526829640, info.value?.tradeFeeNumerator)
        XCTAssertEqual(6254149569805567823, info.value?.tradeFeeDenominator)
        XCTAssertEqual(13700189867744280270, info.value?.ownerTradeFeeNumerator)
        XCTAssertEqual(50083033227356403, info.value?.ownerTradeFeeDenominator)
        XCTAssertEqual(3, info.value?.ownerWithdrawFeeNumerator)
        XCTAssertEqual(1000, info.value?.ownerWithdrawFeeDenominator)
        XCTAssertEqual(1, info.value?.hostFeeNumerator)
        XCTAssertEqual(1000, info.value?.hostFeeDenominator)
    }
}
