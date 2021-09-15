//
//  RenVMRPCClientTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 15/09/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import XCTest
@testable import SolanaSwift

class RenVMRPCClientTests: XCTestCase {
    func testEncodeBody() throws {
        let input = RenVM.MintTransactionInput(
            txid: "YtU3AP9wspScgOI6kgDr1gp49AbS52Mio7Q8JltutDJhgGSz3qkM20Csti1PRGpsJUwYHuqeWBNY_ySoUo_CCw",
            txindex: "0",
            ghash: "Bde-qbf54lElW4RIPc6GkbBkZ0muCAiIL1CEe5rB1Y8",
            gpubkey: "",
            nhash: "Y_dfWQXxRLYMBs8T0S7SVjeh4hdTPzIDpxXUfBJRK2k",
            nonce: "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABU",
            payload: "",
            phash: "xdJGAYb3IzySfn2y3McDwOUAtlPKgic7e_rYBF2FpHA",
            to: "tb1ql7w62elx9ucw4pj5lgw4l028hmuw80sndtntxt",
            amount: "10000"
        )
        
        let hash = "nrRusEWs3bn619zTGc1937EakvCGvjbt5gYr4L2PL_M"
        let selector = RenVM.Selector(mintTokenSymbol: "BTC", chainName: "Solana", direction: .from)
        let version = "1"
        
        let tx = RenVM.ParamsSubmitMint(
            hash: hash,
            selector: selector.toString(),
            version: version,
            in: .init(
                t: .init(),
                v: input
            )
        )
        
        let body = RenVM.RpcClient.Body(
            method: "ren_submitTx",
            params: .init(wrapped: ["tx": tx])
        )
        
        XCTAssertEqual(body.jsonString, #"{"id":1,"jsonrpc":"2.0","method":"ren_submitTx","params":{"tx":{"hash":"nrRusEWs3bn619zTGc1937EakvCGvjbt5gYr4L2PL_M","selector":"BTC\/fromSolana","in":{"t":{"struct":[{"txid":"bytes"},{"txindex":"u32"},{"amount":"u256"},{"payload":"bytes"},{"phash":"bytes32"},{"to":"string"},{"nonce":"bytes32"},{"nhash":"bytes32"},{"gpubkey":"bytes"},{"ghash":"bytes32"}]},"v":{"txindex":"0","txid":"YtU3AP9wspScgOI6kgDr1gp49AbS52Mio7Q8JltutDJhgGSz3qkM20Csti1PRGpsJUwYHuqeWBNY_ySoUo_CCw","ghash":"Bde-qbf54lElW4RIPc6GkbBkZ0muCAiIL1CEe5rB1Y8","amount":"10000","nhash":"Y_dfWQXxRLYMBs8T0S7SVjeh4hdTPzIDpxXUfBJRK2k","payload":"","phash":"xdJGAYb3IzySfn2y3McDwOUAtlPKgic7e_rYBF2FpHA","to":"tb1ql7w62elx9ucw4pj5lgw4l028hmuw80sndtntxt","gpubkey":"","nonce":"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABU"}},"version":"1"}}}"#)
    }
    
    func testQueryBlockState() throws {
        let rpcClient = RenVM.RpcClient(network: .testnet)
        let blockState = try rpcClient.queryBlockState().toBlocking().first()
        XCTAssertNotNil(blockState)
    }
    
    func testQueryConfig() throws {
        let rpcClient = RenVM.RpcClient(network: .testnet)
        let queryConfig = try rpcClient.queryConfig().toBlocking().first()
        XCTAssertNotNil(queryConfig)
    }
}
