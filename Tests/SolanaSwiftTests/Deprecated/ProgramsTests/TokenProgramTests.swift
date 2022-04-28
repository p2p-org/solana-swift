//
//  TokenProgramTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 22/01/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import SolanaSwift

class TokenProgramTests: XCTestCase {
    let publicKey: SolanaSDK.PublicKey = "11111111111111111111111111111111"
    
//    func testInitializeMintInstruction() throws {
//        let instruction = SolanaSDK.TokenProgram.initializeMintInstruction(tokenProgramId: publicKey, mint: publicKey, decimals: 2, authority: publicKey, freezeAuthority: nil)
//        XCTAssertEqual("1nBYrAcY5rLBEoZaGN6hahh3ZhgQTgLmsmunRee8a3zaA42wLZ7aux2HiX6tCKp73MWVj6fDagGuhfTPYGY32UNcis", Base58.encode(instruction.data))
//    }
    
    func testInitializeAccountInstruction() throws {
        let instruction = SolanaSDK.TokenProgram.initializeAccountInstruction(account: publicKey, mint: publicKey, owner: publicKey)
        XCTAssertEqual("2", Base58.encode(instruction.data))
    }
    
    func testTransferInstruction() throws {
        let instruction = SolanaSDK.TokenProgram.transferInstruction(source: publicKey, destination: publicKey, owner: publicKey, amount: 100)
        XCTAssertEqual("3WBgs5fm8oDy", Base58.encode(instruction.data))
    }
    
    func testApproveInstruction() throws {
        let instruction = SolanaSDK.TokenProgram.approveInstruction(account: publicKey, delegate: publicKey, owner: publicKey, amount: 1000)
        XCTAssertEqual("4d5tSvUuzUVM", Base58.encode(instruction.data))
    }
    
    func testMintToInstruction() throws {
        let instruction = SolanaSDK.TokenProgram.mintToInstruction(mint: publicKey, destination: publicKey, authority: publicKey, amount: 1000000000)
        XCTAssertEqual("6AsKhot84V8s", Base58.encode(instruction.data))
    }
    
    func testCloseAccountInstruction() throws {
        let instruction = SolanaSDK.TokenProgram.closeAccountInstruction(account: publicKey, destination: publicKey, owner: publicKey)
        XCTAssertEqual("A", Base58.encode(instruction.data))
    }
}
