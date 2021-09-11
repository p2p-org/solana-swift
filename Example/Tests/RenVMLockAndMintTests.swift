//
//  RenVMLockAndMintTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 09/09/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
@testable import SolanaSwift

class RenVMLockAndMintTests: XCTestCase {
    let destinationAddress: SolanaSDK.PublicKey = "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"
    
    func testSession() throws {
        let sessionDay: Long = 18870
        let session = RenVM.LockAndMint.Session(
            destinationAddress: destinationAddress.data,
            sessionDay: sessionDay
        )
        XCTAssertEqual(session.expiryTime, 1630627200000)
        XCTAssertEqual(session.nonce, "2020202020202020202020202020202020202020202020202020202034396236")
    }
    
    func testGenerateGatewayAddress() throws {
        let lockAndMint = RenVM.LockAndMint(
            network: .testnet,
            provider: RenVM.Mock.provider,
            chain: RenVM.Mock.solanaChain(),
            destinationAddress: destinationAddress.data,
            sessionDay: 18870
        )
        
        let address = try lockAndMint.generateGatewayAddress().toBlocking().first()
        XCTAssertEqual(Base58.encode(address!.bytes), "2NC451uvR7AD5hvWNLQiYoqwQQfvQy2XB6U")
    }
    
//    @Test
//    public void generateGatewayAddressTest() throws Exception {
//        LockAndMint lockAndMint = new LockAndMint(NetworkConfig.TESTNET(), Mock.buildRenVMProvider(),
//                new SolanaChain(Mock.buildSolanaRpcClient(), NetworkConfig.TESTNET()), session);
//
//        assertEquals("2NC451uvR7AD5hvWNLQiYoqwQQfvQy2XB6U", lockAndMint.generateGatewayAddress());
//    }
//
//    @Test
//    public void getDepositStateTest() throws Exception {
//        LockAndMint lockAndMint = new LockAndMint(NetworkConfig.TESTNET(), Mock.buildRenVMProvider(),
//                new SolanaChain(Mock.buildSolanaRpcClient(), NetworkConfig.TESTNET()),
//                new Session(destinationAddress, Utils.generateNonce(18874), 18874, Utils.getSessionExpiry(18874)));
//        String gatewayAddress = lockAndMint.generateGatewayAddress();
//
//        assertEquals("2MyJ7zQxBCnwKuRNoE3UYD2cb9MDjdkacaF", gatewayAddress);
//        assertEquals("LLg3jxVXS4NEixjaBOUXocRqaK_Y0wk5HPshI1H3e6c",
//                lockAndMint.getDepositState("01d32c22d721d7bf0cd944fc6e089b01f998e1e77db817373f2ee65e40e9462a", "0",
//                        "10000").txHash);
//    }
}
