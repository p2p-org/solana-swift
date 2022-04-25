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
    
    func testGetTokenWallets() throws {
        let datas = try solanaSDK.getTokenWallets(account: "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG").toBlocking().first()
        XCTAssertNotEqual(datas?.count, 0)
    }
    
    func testGetAccountInfo() throws {
        let accountInfo = try solanaSDK.getAccountInfo(account: "8J5wZ4Lo7QSwFWwBfWsWUgsbH4Jr44RFsEYj6qFdXYhM", decodedTo: SolanaSDK.AccountInfo.self).toBlocking().first()?.data
        XCTAssertEqual(accountInfo?.mint.base58EncodedString, "9S4t2NEAiJVMvPdRYKVrfJpBafPBLtvbvyS3DecojQHw")
        XCTAssertEqual(accountInfo?.owner.base58EncodedString, "HnXJX1Bvps8piQwDYEYC6oea9GEkvQvahvRj3c97X9xr")
    }
    
    func testGetMintData() throws {
        let mintData = try solanaSDK.getMintData(mintAddress: "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v").toBlocking().first()
        XCTAssertEqual(mintData?.mintAuthority?.base58EncodedString, "2wmVCSfPxGPjrnMMn7rchp4uaeoTqN39mXFC2zhPdri9")
        XCTAssertEqual(mintData?.decimals, 6)
        XCTAssertEqual(mintData?.freezeAuthority?.base58EncodedString, "3sNBr7kMccME5D55xNgsmYpZnzPgP2g12CixAajXypn6")
    }

    func testGetMultipleMintDatas() throws {
        let datas = try solanaSDK.getMultipleMintDatas(mintAddresses: ["EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v", "Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB"]).toBlocking().first()
        
        // usdc
        let usdc = datas?["EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v"]
        XCTAssertEqual(usdc?.mintAuthority?.base58EncodedString, "2wmVCSfPxGPjrnMMn7rchp4uaeoTqN39mXFC2zhPdri9")
        XCTAssertEqual(usdc?.decimals, 6)
        XCTAssertEqual(usdc?.freezeAuthority?.base58EncodedString, "3sNBr7kMccME5D55xNgsmYpZnzPgP2g12CixAajXypn6")
        
        // usdt
        let usdt = datas?["Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB"]
        XCTAssertEqual(usdt?.mintAuthority?.base58EncodedString, "Q6XprfkF8RQQKoQVG33xT88H7wi8Uk1B1CC7YAs69Gi")
        XCTAssertEqual(usdt?.decimals, 6)
        XCTAssertEqual(usdt?.freezeAuthority?.base58EncodedString, "Q6XprfkF8RQQKoQVG33xT88H7wi8Uk1B1CC7YAs69Gi")
    }
    
    func testCheckIfAssociatedTokenAccountExists() throws {
        let exist = try solanaSDK.checkIfAssociatedTokenAccountExists(owner: "9sdwzJWooFrjNGVX6GkkWUG9GyeBnhgJYqh27AsPqwbM", mint: "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v").toBlocking().first()!
        XCTAssertTrue(exist)
        
        let exist2 = try solanaSDK.checkIfAssociatedTokenAccountExists(owner: "9sdwzJWooFrjNGVX6GkkWUG9GyeBnhgJYqh27AsPqwbM", mint: "2FPyTwcZLUg1MDrwsyoP4D6s1tM7hAkHYRjkNb5w6Pxk").toBlocking().first()!
        XCTAssertFalse(exist2)
    }
}
