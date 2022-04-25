//
//  PublicKeyTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 01/09/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
@testable import SolanaSwift

class PublicKeyTests: XCTestCase {
    func testCreateWithSeeds() throws {
        let defaultPublicKey: SolanaSDK.PublicKey = "11111111111111111111111111111111"
        let derivedKey = try SolanaSDK.PublicKey.createWithSeed(
            fromPublicKey: defaultPublicKey,
            seed: "limber chicken: 4/45",
            programId: defaultPublicKey
        )
        XCTAssertEqual(derivedKey, "9h1HyLCW5dZnBVap8C5egQ9Z6pHyjsh5MNy83iPqqRuq")
    }
}
