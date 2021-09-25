//
//  RenVMHashTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 10/09/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import XCTest
@testable import SolanaSwift

class RenVMHashTests: XCTestCase {
    func testSha256() throws {
        let data = Base58.decode("D4Rioa1Zh1jMummwpqx8m2SkhSATN").sha256()
        XCTAssertEqual(Base58.encode(data), "73hrfBgvit4TbtXpZuFe2exKDqWs5h2DFZ6keiiQizyc")
    }
    
    func testKeccak256() throws {
        let bytes = "BTC/toSolana".keccak256
        XCTAssertEqual(Base58.encode(bytes), "2XWUS8dNzaAFeDk6e6Q4dsojE3n9jncAZ9nNBpCJWEgZ")
    }
    
    func testGenerateSHash() throws {
        let bytes = RenVM.Hash.generateSHash(selector: .init(mintTokenSymbol: "BTC", chainName: "Solana", direction: .to)).bytes
        XCTAssertEqual(Base58.encode(bytes), "2XWUS8dNzaAFeDk6e6Q4dsojE3n9jncAZ9nNBpCJWEgZ")
    }
    
    func testGeneratePHash() throws {
        let bytes = RenVM.Hash.generatePHash().bytes
        XCTAssertEqual(Base58.encode(bytes), "EKDHSGbrGztomDfuiV4iqiZ6LschDJPsFiXjZ83f92Md")
    }
    
    func testGenerateGHash() throws {
        let bytes = RenVM.Hash.generateGHash(
            to: "34cef1aee9a983b47366dddb37f5327263737f3551cf4ce30125668c41331a80",
            tokenIdentifier: "16ac6fb8b800ff9e24220479d69d38b59a077966f500c7bbd3435dad78d8fc02",
            nonce: Base58.decode("3AQTaduKvYWFTu1ExZSQK1hQp5jSZ2yEt4KzsASghu2T")
        ).bytes
        
        XCTAssertEqual(Base58.encode(bytes), "2dpw381hu88DTX3VVw78LhqvrPDfyvXyuyArqGouzNYa")
    }
    
    func testGenerateNHash() throws {
        let data = RenVM.Hash.generateNHash(
            nonce: Base58.decode("3AQTaduKvYWFTu1ExZSQK1hQp5jSZ2yEt4KzsASghu3E"),
            txId: Base58.decode("3r2qaGgK1Pvj6ExUqC91QexvFyAXzWA9P3WDPwAMW8me"),
            txIndex: 0
        )
        
        XCTAssertEqual(data.base64urlEncodedString(), "vAOtS_KYooAdS8u0RDJ1ANa-HV1w4vCZSgcrE62GA6U")
    }
    
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
        
        let data = try mintTx
            .hash(selector: .init(
                    mintTokenSymbol: RenVM.Mock.mintToken,
                    chainName: "Solana",
                    direction: .to
            ), version: RenVM.Mock.version
        )
        
        XCTAssertEqual(data.base64urlEncodedString(), "3eT3xmt8h9wW9OZVvfV-BQo5nm70c_ClEqe4zryBq54")
    }
}
