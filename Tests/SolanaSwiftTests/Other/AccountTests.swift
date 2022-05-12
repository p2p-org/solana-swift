//
//  AccountTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 11/6/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
import SolanaSwift
import TweetNacl

class AccountTests: XCTestCase {
    func testCreateAccountFromSecretKey() throws {
        let secretKey = Base58.decode("4Z7cXSyeFR8wNGMVXUE1TwtKn5D5Vu7FzEv69dokLv7KrQk7h6pu4LF8ZRR9yQBhc7uSM6RTTZtU1fmaxiNrxXrs")
        XCTAssertNotNil(secretKey)
        
        let account = try Account(secretKey: Data(secretKey))
        
        XCTAssertEqual("QqCCvshxtqMAL2CVALqiJB7uEeE5mjSPsseQdDzsRUo", account.publicKey.base58EncodedString)
        XCTAssertEqual(64, account.secretKey.count)
    }
    
    func testDerivedKeychain() throws {
        var keychain = try Keychain(seedString: "miracle pizza supply useful steak border same again youth silver access hundred", network: "mainnet-beta")!
        
        keychain = try keychain.derivedKeychain(at: "m/501'/0'/0/0")
        
        let keys = try NaclSign.KeyPair.keyPair(fromSeed: keychain.privateKey!)
        
        XCTAssertEqual([UInt8](keys.secretKey), [109, 13, 53, 177, 69, 45, 146, 184, 62, 55, 105, 133, 210, 89, 131, 218, 248, 101, 47, 64, 81, 56, 229, 25, 173, 154, 12, 41, 66, 143, 230, 117, 39, 247, 185, 4, 85, 137, 50, 166, 147, 184, 221, 75, 110, 103, 16, 222, 41, 94, 247, 132, 43, 62, 172, 243, 95, 204, 190, 143, 153, 16, 10, 197])
    }
    
    func testRestoreAccountFromSeedPhrase() async throws {
        let phrase12 = "miracle pizza supply useful steak border same again youth silver access hundred"
            .components(separatedBy: " ")
        let account12 = try await Account(phrase: phrase12, network: .mainnetBeta)
        XCTAssertEqual(account12.publicKey.base58EncodedString, "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG")
        
        let phrase24 = "budget resource fluid mutual ankle salt demise long burst sting doctor ozone risk magic wrap clap post pole jungle great update air interest abandon"
            .components(separatedBy: " ")
        let account24 = try await Account(phrase: phrase24, network: .mainnetBeta)
        XCTAssertEqual(account24.publicKey.base58EncodedString, "9avcmC97zLPwHKXiDz6GpXyjvPn9VcN3ggqM5gsRnjvv")
    }

}
