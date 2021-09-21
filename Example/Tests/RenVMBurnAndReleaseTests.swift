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

class RenVMBurnAndReleaseTests: RestAPITests {
    override var endpoint: SolanaSDK.APIEndPoint {
        .init(url: "https://api.devnet.solana.com", network: .devnet)
    }
    
    override var overridingAccount: String? {
        "matter outer client aspect pear cigar caution robust easily merge dwarf wide short sail unusual indicate roast giraffe clay meat crowd exile curious vibrant"
    }
    
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
    
    func testBurnAndRelease() throws {
        let rpcClient = RenVM.RpcClient(network: .devnet)
        
        let solanaChain = try RenVM.SolanaChain.load(client: rpcClient, solanaClient: solanaSDK).toBlocking().first()!
        
        let recipient = "tb1ql7w62elx9ucw4pj5lgw4l028hmuw80sndtntxt"
        
        let burnAndRelease = RenVM.BurnAndRelease(
            rpcClient: rpcClient,
            chain: solanaChain,
            mintTokenSymbol: "BTC",
            version: "1",
            burnTo: "Bitcoin"
        )
        
        let details = try burnAndRelease.submitBurnTransaction(
            account: account.publicKey.data,
            amount: "9000",
            recipient: recipient,
            signer: account.secretKey
        ).toBlocking().first()
        
        
    }
}
