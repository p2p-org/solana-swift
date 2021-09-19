//
//  RenVMSolanaChainTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 09/09/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import RxSwift
@testable import SolanaSwift

class RenVMSolanaChainTests: XCTestCase {
    func testGatewayRegistryStateKey() throws {
        let network = RenVM.Network.testnet
        
        let pubkey = try SolanaSDK.PublicKey(string: network.gatewayRegistry)
        XCTAssertEqual(pubkey, "REGrPFKQhRneFFdUV3e9UDdzqUJyS6SKj88GdXFCRd2")
        
        let stateKey = try SolanaSDK.PublicKey.findProgramAddress(seeds: [RenVM.SolanaChain.gatewayRegistryStateKey.data(using: .utf8)!], programId: pubkey)
        XCTAssertEqual(stateKey.0, "4aMET2gUF29qk8G4Zbg2bWxLkFaTWuTYqnvQqFY16J6c")
    }
    
    func testDecodeGatewayRegistryData() throws {
        let data = Data(base64Encoded: RenVM.Mock.mockGatewayRegistryData)!
        var pointer = 0
        let gatewayRegistryData = try RenVM.SolanaChain.GatewayRegistryData(buffer: data, pointer: &pointer)
        
        XCTAssertTrue(gatewayRegistryData.isInitialized)
        XCTAssertEqual(gatewayRegistryData.owner, "GQy1uiRSpfkb3xxRXFuNhz7cCoa5P9NgEDAWyykMGB3J")
        XCTAssertEqual(gatewayRegistryData.count, 7)
        
        XCTAssertEqual(gatewayRegistryData.selectors.count, 32)
        XCTAssertEqual(gatewayRegistryData.selectors.first, "2XWUS8dNzaAFeDk6e6Q4dsojE3n9jncAZ9nNBpCJWEgZ")
        XCTAssertEqual(gatewayRegistryData.selectors[5], "58no1qGYUB4FN8KKDEC2TRFRtfJeKTvXQeTeC9jhga7x")
        XCTAssertEqual(gatewayRegistryData.selectors[7], "11111111111111111111111111111111")
        XCTAssertEqual(gatewayRegistryData.selectors[31], "11111111111111111111111111111111")
        
        XCTAssertEqual(gatewayRegistryData.gateways.count, 32)
        XCTAssertEqual(gatewayRegistryData.gateways[0], "FsEACSS3nKamRKdJBaBDpZtDXWrHR2nByahr4ReoYMBH")
        XCTAssertEqual(gatewayRegistryData.gateways[5], "4tcoeQfSLpyd3qqnJBweTkFFqYjvn4hsv9uWP7GM94XK")
        XCTAssertEqual(gatewayRegistryData.gateways[7], "11111111111111111111111111111111")
        XCTAssertEqual(gatewayRegistryData.gateways[31], "11111111111111111111111111111111")
    }
    
    func testDecodeGatewayStateData() throws {
        let data = Data(base64Encoded: RenVM.Mock.mockGatewayStateData)!
        var pointer = 0
        let gatewayRegistryData = try RenVM.SolanaChain.GatewayStateData(buffer: data, pointer: &pointer)
        
        XCTAssertEqual(gatewayRegistryData.isInitialized, true)
        XCTAssertEqual(gatewayRegistryData.renVMAuthority.bytes.toHexString(), "44bb4ef43408072bc888afd1a5986ba0ce35cb54")
        XCTAssertEqual(gatewayRegistryData.selectors.bytes, [22, 172, 111, 184, 184, 0, 255, 158, 36, 34, 4, 121, 214, 157, 56, 181, 154, 7, 121, 102, 245, 0, 199, 187, 211, 67, 93, 173, 120, 216, 252, 2])
        XCTAssertEqual(gatewayRegistryData.burnCount, 8)
    }
    
    func testResolveTokenGatewayContract() throws {
        XCTAssertEqual(try RenVM.Mock.solanaChain().resolveTokenGatewayContract(mintTokenSymbol: RenVM.Mock.mintToken), "FsEACSS3nKamRKdJBaBDpZtDXWrHR2nByahr4ReoYMBH")
    }
    
    func testGetSPLTokenPubkey() throws {
        XCTAssertEqual(try RenVM.Mock.solanaChain().getSPLTokenPubkey(mintTokenSymbol: RenVM.Mock.mintToken), "FsaLodPu4VmSwXGr3gWfwANe4vKf8XSZcCh1CEeJ3jpD")
    }
    
    func testGetAssociatedTokenAccount() throws {
        let pubkey: SolanaSDK.PublicKey = "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"
        XCTAssertEqual(Base58.encode(try RenVM.Mock.solanaChain().getAssociatedTokenAddress(address: pubkey.data, mintTokenSymbol: RenVM.Mock.mintToken).bytes), "4Z9Dv58aSkG9bC8stA3aqsMNXnSbJHDQTDSeddxAD1tb")
    }
    
    func testBuildRenVMMessage() throws {
        let bytes = try RenVM.SolanaChain.buildRenVMMessage(
            pHash: Data(base64urlEncoded: "xdJGAYb3IzySfn2y3McDwOUAtlPKgic7e_rYBF2FpHA")!,
            amount: "9186",
            token: Data(Base58.decode("2XWUS8dNzaAFeDk6e6Q4dsojE3n9jncAZ9nNBpCJWEgZ")),
            to: "4Z9Dv58aSkG9bC8stA3aqsMNXnSbJHDQTDSeddxAD1tb",
            nHash: Data(base64urlEncoded: "L1kPFl6zMw_k_6Vc6GZksrLeT25wROFmwbREyzlv9OQ")!
        ).bytes
        XCTAssertEqual(Base58.encode(bytes), "71nK5AmnXQVYxHsA1JCF96MUuTxkgUKfXRPX97EZ5D41c8VFDyDeMunKmVp5tFbVfWNLg9S9W3Z5wKy2ZhYeMW4HJQV1tvnbizp5jM3E1wNVrvDJAcBS6xoMEMoVasZDJgvtmHtcSKNMRTJTzCf5ZBimkvdBKX9V9w81Bn8TX8apojeJQGKK3XMtAeoJWTwKqorTdewKQYwVg7iqn5xE5B1zgMy")
    }
    
//    func testFindMintByDepositDetails() throws {
//        let pHash = Data(base64urlEncoded: "xdJGAYb3IzySfn2y3McDwOUAtlPKgic7e_rYBF2FpHA")!
//        let amount = "9186"
//        let to: SolanaSDK.PublicKey = "4Z9Dv58aSkG9bC8stA3aqsMNXnSbJHDQTDSeddxAD1tb"
//        let nHash = Data(base64urlEncoded: "L1kPFl6zMw_k_6Vc6GZksrLeT25wROFmwbREyzlv9OQ")!
//
//        let solanaChain = RenVM.Mock.solanaChain()
//
//        try solanaChain.findMintByDepositDetail(nHash: nHash, pHash: pHash, to: to, mintTokenSymbol: RenVM.Mock.mintToken, amount: amount).toBlocking().first()
//    }
}
