//
//  RenVMUtilsTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 14/09/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
@testable import SolanaSwift

class RenVMUtilsTests: XCTestCase {

    func testFixSignatureSimple() throws {
        let string = "fypvW39VUS6tB8basjmi3YsSn_GR7uLTw_lGcJhQYFcRVemsA1LkF8FQKH_1XJR-bQGP6AXsPbnmB1H8AvKBWgA"
        let data = try Data(base64urlEncoded: string)?.fixSignatureSimple()
        XCTAssertEqual("CDsK2CsmBnLqupzsv9EeDHwc5ZYQxXt9LKzpkmusasc5z2LdDiKHqnCXpiCZTEXDYZtP7JgY4Ur9fkAU5RWSwxrnn", Base58.encode(data!.bytes))
    }
    
    func testAddressToBytes() throws {
        let bytes = try RenVM.BurnAndRelease.addressToBytes(address: "tb1ql7w62elx9ucw4pj5lgw4l028hmuw80sndtntxt")
        XCTAssertEqual("0x" + bytes.hexString, "0x00ff9da567e62f30ea8654fa1d5fbd47bef8e3be13")
    }
}
