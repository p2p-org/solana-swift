//
//  RenVMBurnAndReleaseTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 14/09/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import XCTest
@testable import SolanaSwift

class RenVMBurnAndReleaseTests: XCTestCase {
    func testBurnState() throws {
        let burnAndRelease = RenVM.BurnAndRelease(
            rpcClient: RenVM.Mock.rpcClient,
            chain: RenVM.Mock.solanaChain(),
            mintTokenSymbol: "BTC",
            version: "1",
            burnTo: "Bitcoin"
        )
        
        let burnDetails = RenVM.BurnDetails(
            confirmedSignature: "2kNe8duPRcE9xxKLLVP92e9TBH5WvmVVWQJ18gEjqhgxsrKtBEBVfeXNFz5Un3yEEQJZkxY2ysQR4dGQaytnDM1i",
            nonce: 35,
            recipient: "tb1ql7w62elx9ucw4pj5lgw4l028hmuw80sndtntxt"
        )
        
        let burnState = try burnAndRelease.getBurnState(burnDetails: burnDetails, amount: "1000")
        
        XCTAssertEqual(burnState.txHash, "I_HJMksqVC5_-0G9FE_z8AORRDMoxl1vZbSGEc2VfJ4")
    }
//    @Test
//    public void getBurnStateTest() throws Exception {
//        BurnAndRelease burnAndRelease = new BurnAndRelease(NetworkConfig.TESTNET());
//        BurnDetails burnDetails = new BurnDetails();
//        burnDetails.confirmedSignature = "2kNe8duPRcE9xxKLLVP92e9TBH5WvmVVWQJ18gEjqhgxsrKtBEBVfeXNFz5Un3yEEQJZkxY2ysQR4dGQaytnDM1i";
//        burnDetails.nonce = BigInteger.valueOf(35);
//        burnDetails.recepient = "tb1ql7w62elx9ucw4pj5lgw4l028hmuw80sndtntxt";
//        assertEquals("I_HJMksqVC5_-0G9FE_z8AORRDMoxl1vZbSGEc2VfJ4",
//                burnAndRelease.getBurnState(burnDetails, "1000").txHash);
//    }
}
