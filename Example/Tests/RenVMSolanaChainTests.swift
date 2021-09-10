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
        let data = Data(base64Encoded: mockGatewayRegistryData)!
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
    
    func testResolveTokenGatewayContract() throws {
        let solanaChain = try RenVM.SolanaChain.load(
            client: MockRenVMRpcClient(.testnet),
            solanaClient: MockSolanaClient(),
            network: .testnet
        ).toBlocking().first()
        XCTAssertEqual(try solanaChain?.resolveTokenGatewayContract(), "FsEACSS3nKamRKdJBaBDpZtDXWrHR2nByahr4ReoYMBH")
    }
    
    func testGetSPLTokenPubkey() throws {
        let solanaChain = try RenVM.SolanaChain.load(
            client: MockRenVMRpcClient(.testnet),
            solanaClient: MockSolanaClient(),
            network: .testnet
        ).toBlocking().first()
        XCTAssertEqual(try solanaChain?.getSPLTokenPubkey(), "FsaLodPu4VmSwXGr3gWfwANe4vKf8XSZcCh1CEeJ3jpD")
    }
    
    func testGetAssociatedTokenAccount() throws {
        let solanaChain = try RenVM.SolanaChain.load(
            client: MockRenVMRpcClient(.testnet),
            solanaClient: MockSolanaClient(),
            network: .testnet
        ).toBlocking().first()
        XCTAssertEqual(try solanaChain?.getAssociatedTokenAddress(address: "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"), "4Z9Dv58aSkG9bC8stA3aqsMNXnSbJHDQTDSeddxAD1tb")
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
//        let pHash = Data(base64urlEncoded: "xdJGAYb3IzySfn2y3McDwOUAtlPKgic7e_rYBF2FpHA")
//        let amount = "9186"
//        let to: SolanaSDK.PublicKey = "4Z9Dv58aSkG9bC8stA3aqsMNXnSbJHDQTDSeddxAD1tb"
//        let nHash = Data(base64urlEncoded: "L1kPFl6zMw_k_6Vc6GZksrLeT25wROFmwbREyzlv9OQ")
//
//        let solanaChain = try RenVM.SolanaChain.load(
//            client: MockRenVMRpcClient(.testnet),
//            network: .testnet
//        ).toBlocking().first()
//
//        assertEquals("", solanaChain.findMintByDepositDetails(nHash, pHash, to, amount));
//                ;
//    }
}

private struct MockRenVMRpcClient: RenVMRpcClientType {
    init(_ network: RenVM.Network) {
        
    }
    
    func call<T>(endpoint: String, params: Encodable) -> Single<T> where T : Decodable {
        fatalError()
    }
}

private struct MockSolanaClient: RenVMSolanaAPIClientType {
    func getAccountInfo<T>(account: String, decodedTo: T.Type) -> Single<SolanaSDK.BufferInfo<T>> where T : DecodableBufferLayout {
        if decodedTo == RenVM.SolanaChain.GatewayRegistryData.self {
            let data = Data(base64Encoded: mockGatewayRegistryData)!
            var pointer = 0
            let gatewayRegistryData = try! RenVM.SolanaChain.GatewayRegistryData(buffer: data, pointer: &pointer)
            return .just(.init(lamports: 0, owner: "", data: gatewayRegistryData as! T, executable: true, rentEpoch: 0))
        }
        fatalError()
    }
    
    func getMintData(mintAddress: String, programId: String) -> Single<SolanaSDK.Mint> {
        fatalError()
    }
    
    func getConfirmedSignaturesForAddress2(account: String, configs: SolanaSDK.RequestConfiguration?) -> Single<[SolanaSDK.SignatureInfo]> {
        fatalError()
    }
}

private var mockGatewayRegistryData: String { "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"
}
