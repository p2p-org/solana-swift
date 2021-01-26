//
//  RestAPIPoolTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 26/01/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest

class RestAPIPoolTests: RestAPITests {
    override var network: String {"mainnet-beta"}
    func testGetTokenAccountBalance() throws {
        let pools = try solanaSDK.getPools(swapProgramId: "9qvG1zUp8xF1Bi4m6UdRNby1BAAuaDrUxSpv4CmRRMjL").toBlocking().first()
        XCTAssertNotNil(pools)
        XCTAssertNotEqual(pools!.count, 0)
    }
}


