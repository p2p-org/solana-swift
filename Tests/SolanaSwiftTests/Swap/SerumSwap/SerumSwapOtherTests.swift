//
//  SerumSwapOtherTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 26/08/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import RxBlocking
@testable import SolanaSwift

class SerumSwapOtherTests: XCTestCase {

    func testCreateVaultOwner() throws {
        let vault = try SerumSwap.getVaultOwnerAndNonce(marketPublicKey: "ByRys5tuUWDgL73G8JBAEfkdFf8JWBzPBDHsBVQ5vbQA").toBlocking().first()
        let vaultOwner = vault!.vaultOwner
        XCTAssertEqual(vaultOwner.base58EncodedString, "GVV4ZT9pccwy9d17STafFDuiSqFbXuRTdvKQ1zJX6ttX")
    }

    func testSighash() throws {
        let swap = try SerumSwap.sighash(ixName: "swap")
        XCTAssertEqual(swap.bytes, [248, 198, 158, 145, 225, 117, 135, 200])
        
        let swapTransitive = try SerumSwap.sighash(ixName: "swapTransitive")
        XCTAssertEqual(swapTransitive.bytes, [129, 109, 254, 207, 31, 192, 47, 51])
    }
}
