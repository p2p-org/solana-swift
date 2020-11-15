//
//  KeychainTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 15/11/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
import SolanaSwift
import TweetNacl

class KeychainTests: XCTestCase {

    func testDerivedKeychain() throws {
        var keychain = try Keychain(seedString: "miracle pizza supply useful steak border same again youth silver access hundred", network: "mainnet-beta")
        
        keychain = try keychain.derivedKeychain(at: "m/501'/0'/0/0")
        
        let keys = try NaclSign.KeyPair.keyPair(fromSeed: keychain.privateKey!)
        
        XCTAssertEqual([UInt8](keys.secretKey), [109, 13, 53, 177, 69, 45, 146, 184, 62, 55, 105, 133, 210, 89, 131, 218, 248, 101, 47, 64, 81, 56, 229, 25, 173, 154, 12, 41, 66, 143, 230, 117, 39, 247, 185, 4, 85, 137, 50, 166, 147, 184, 221, 75, 110, 103, 16, 222, 41, 94, 247, 132, 43, 62, 172, 243, 95, 204, 190, 143, 153, 16, 10, 197])
    }

}
