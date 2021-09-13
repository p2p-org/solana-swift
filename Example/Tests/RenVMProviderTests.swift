//
//  RenVMProviderTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 13/09/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
@testable import SolanaSwift

class RenVMProviderTests: XCTestCase {
    func testHashTransactionMint() throws {
        let mintTx = RenVM.MintTransactionInput(
            txid: "tNWySkdaqjoHEJddH3jlVTwLFOJikwjxlGNiLDXC2ns",
            txindex: "1",
            ghash: "ePjNFLH84OxeVjzihYVWVbFZhyFM0ZpegupiBUt76V8",
            gpubkey: "Aw3WX32ykguyKZEuP0IT3RUOX5csm3PpvnFNhEVhrDVc",
            nhash: "_jRsczCRyXm_Wud_oLxiHQpUTyf0q3iUy7FBpR-m5VQ",
            nonce: "ICAgICAgICAgICAgICAgICAgICAgICAgICAgIDQ5Yjg",
            payload: "",
            phash: "xdJGAYb3IzySfn2y3McDwOUAtlPKgic7e_rYBF2FpHA",
            to: "4Z9Dv58aSkG9bC8stA3aqsMNXnSbJHDQTDSeddxAD1tb",
            amount: "10000"
        )
        
        XCTAssertEqual(try mintTx.hash().base64urlEncodedString(), "3eT3xmt8h9wW9OZVvfV-BQo5nm70c_ClEqe4zryBq54")
    }
}
