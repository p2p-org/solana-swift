//
//  RenVMScriptTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 10/09/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import XCTest
@testable import SolanaSwift

class RenVMScriptTests: XCTestCase {
    func testGatewayScript() throws {
        let gGubKeyHash = Base58.decode("3ou4DtLwVsvkX76Ay3q5H4ccKQdw")
        let gHash = Base58.decode("2zB96eXCpNt4oHXqxeHjRyphdWaGYz1attyyjcSoqpV1")
        let gS = RenVM.Script.gatewayScript(gGubKeyHash: Data(gGubKeyHash), gHash: Data(gHash))
        XCTAssertEqual(Base58.encode(gS.bytes), "2HnZgcJKmdCVaP9mMdzHM1gsEhbDfusQLZAupRU6AnZnD4yFsHKoUCzb3JWTmKM6PscSpRSbbLAF4y4fu")
    }
    
    func testCreateAddressByteArray() throws {
        let gGubKeyHash = Data(Base58.decode("ucy1GEq7vwmysYhuGMedLFDUXUQchvfKAQLxEopvzU9h")).hash160
        let gHash = Base58.decode("2zB96eXCpNt4oHXqxeHjRyphdWaGYz1attyyjcSoqpV1")
        let prefix: UInt8 = 0xc4
        let addressBytes = RenVM.Script.createAddressByteArray(gGubKeyHash: gGubKeyHash, gHash: Data(gHash), prefix: Data([prefix]))
        XCTAssertEqual(Base58.encode(addressBytes.bytes), "2MuoKWBjtBEhxgrE6bvY9TGjkGUTPeEq1Ja")
    }
    
    func testChecksum() throws {
        let hash = Base58.decode("D4Rioa1Zh1jMummwpqx8m2SkhSATN")
        XCTAssertEqual(Base58.encode(RenVM.Script.checksum(hash: Data(hash)).bytes), "2vuP8n")
    }
}
