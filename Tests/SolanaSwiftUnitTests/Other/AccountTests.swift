//
//  AccountTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 11/6/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import SolanaSwift
import TweetNacl
import XCTest

class AccountTests: XCTestCase {
    func testRestoreAccountFromSecretKey() throws {
        let secretKey = Base58
            .decode("4Z7cXSyeFR8wNGMVXUE1TwtKn5D5Vu7FzEv69dokLv7KrQk7h6pu4LF8ZRR9yQBhc7uSM6RTTZtU1fmaxiNrxXrs")
        XCTAssertNotNil(secretKey)

        let account = try Account(secretKey: Data(secretKey))

        XCTAssertEqual("QqCCvshxtqMAL2CVALqiJB7uEeE5mjSPsseQdDzsRUo", account.publicKey.base58EncodedString)
        XCTAssertEqual(64, account.secretKey.count)
    }

    func testRestoreAccountFromSeedPhrase() async throws {
        let phrase12 = "miracle pizza supply useful steak border same again youth silver access hundred"
            .components(separatedBy: " ")
        let account12 = try await Account(phrase: phrase12, network: .mainnetBeta)
        XCTAssertEqual(account12.publicKey.base58EncodedString, "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG")

        let phrase24 =
            "budget resource fluid mutual ankle salt demise long burst sting doctor ozone risk magic wrap clap post pole jungle great update air interest abandon"
                .components(separatedBy: " ")
        let account24 = try await Account(phrase: phrase24, network: .mainnetBeta)
        XCTAssertEqual(account24.publicKey.base58EncodedString, "9avcmC97zLPwHKXiDz6GpXyjvPn9VcN3ggqM5gsRnjvv")
    }
    
    func testRestoreAccountFromMnemonic() async throws {
        let mnemonic12 = try Mnemonic(phrase: "miracle pizza supply useful steak border same again youth silver access hundred"
            .components(separatedBy: " "))
        let account12 = try await Account(mnemonic: mnemonic12, network: .mainnetBeta, derivablePath: .init(type: .deprecated, walletIndex: 0))
        XCTAssertEqual(account12.publicKey, "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG")
        
        let mnemonic24 = try Mnemonic(phrase: "budget resource fluid mutual ankle salt demise long burst sting doctor ozone risk magic wrap clap post pole jungle great update air interest abandon"
            .components(separatedBy: " "))
        let account24 = try await Account(mnemonic: mnemonic24, network: .mainnetBeta, derivablePath: .default)
        XCTAssertEqual(account24.publicKey, "9avcmC97zLPwHKXiDz6GpXyjvPn9VcN3ggqM5gsRnjvv")
    }
    
    func testRestoreAccountFromNonMnemonicSeedPhrase() async throws {
        let phrase = ["y", "5", "H", "M", "p", "D", "^", "G", "6", "3", "9", "x", "a", "b", "^", "8"]
        let account = try await Account(nonMnemonicPhrase: phrase, salt: "", network: .mainnetBeta, derivablePath: .default)
        XCTAssertEqual(account.publicKey, "7TJ2AEYmkUYJ3ESQv5B7Z1HwrTG9hUdj3PpqZn7DCxfo")
    }
    
    // MARK: - Deprecated derivable path

    func testDerivedKeychain() throws {
        var keychain = try Keychain(
            seedString: "miracle pizza supply useful steak border same again youth silver access hundred",
            network: "mainnet-beta"
        )!

        keychain = try keychain.derivedKeychain(at: "m/501'/0'/0/0")

        let keys = try NaclSign.KeyPair.keyPair(fromSeed: keychain.privateKey!)

        XCTAssertEqual(
            [UInt8](keys.secretKey),
            [109,13,53,177,69,45,146,184,62,55,105,133,210,89,131,218,248,101,47,64,81,56,229,25,173,154,12,41,66,143,230,117,39,247,185,4,85,137,50,166,147,184,221,75,110,103,16,222,41,94,247,132,43,62,172,243,95,204,190,143,153,16,10,197]
        )
    }
}
