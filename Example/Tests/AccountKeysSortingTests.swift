//
//  AccountKeysSortingTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 02/03/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import SolanaSwift

class AccountKeysSortingTests: XCTestCase {
    var sender: SolanaSDK.PublicKey!

    override func setUpWithError() throws {
        sender = try SolanaSDK.PublicKey(string: "F5Ju1iFZ8yf1iTB1YcHVG23rcgm2ubBtiL6nZSyVvnEW")
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSendSOL() throws {
        let receiver = try SolanaSDK.PublicKey(string: "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG")
        let program = try SolanaSDK.PublicKey(string: "11111111111111111111111111111111")
        
        var accountKeys: [SolanaSDK.Account.Meta] = [
            .init(publicKey: sender, isSigner: true, isWritable: true),
            .init(publicKey: receiver, isSigner: false, isWritable: true),
            .init(publicKey: program, isSigner: false, isWritable: false)
        ]
        
        accountKeys.sort()
        
        let account0 = accountKeys[0]
        XCTAssertEqual(account0.publicKey.base58EncodedString, "F5Ju1iFZ8yf1iTB1YcHVG23rcgm2ubBtiL6nZSyVvnEW")
        XCTAssertEqual(account0.isSigner, true)
        XCTAssertEqual(account0.isWritable, true)
        
        let account1 = accountKeys[1]
        XCTAssertEqual(account1.publicKey.base58EncodedString, "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG")
        XCTAssertEqual(account1.isSigner, false)
        XCTAssertEqual(account1.isWritable, true)
        
        let account2 = accountKeys[2]
        XCTAssertEqual(account2.publicKey.base58EncodedString, "11111111111111111111111111111111")
        XCTAssertEqual(account2.isSigner, false)
        XCTAssertEqual(account2.isWritable, false)
    }
    
    func testSendSPLToken() throws {
        let tokenFrom = try SolanaSDK.PublicKey(string: "Hj33AdXWfzPid6so1iZjcSDDuGxfT63mgfHN7i8JiURV")
        let tokenTo = try SolanaSDK.PublicKey(string: "BvKyAQNCsgWC7XDXKAGEeUyumKJXcmBEfLEYxaapqASZ")
        let program = try SolanaSDK.PublicKey(string: "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA")
        
        var accountKeys: [SolanaSDK.Account.Meta] = [
            .init(publicKey: tokenFrom, isSigner: false, isWritable: true),
            .init(publicKey: tokenTo, isSigner: false, isWritable: true),
            .init(publicKey: sender, isSigner: true, isWritable: true),
            .init(publicKey: program, isSigner: false, isWritable: false)
        ]
        accountKeys.sort()
        
        let account0 = accountKeys[0]
        XCTAssertEqual(account0.publicKey.base58EncodedString, "F5Ju1iFZ8yf1iTB1YcHVG23rcgm2ubBtiL6nZSyVvnEW")
        XCTAssertEqual(account0.isSigner, true)
        XCTAssertEqual(account0.isWritable, true)
        
        let account1 = accountKeys[1]
        XCTAssertEqual(account1.publicKey.base58EncodedString, "Hj33AdXWfzPid6so1iZjcSDDuGxfT63mgfHN7i8JiURV")
        XCTAssertEqual(account1.isSigner, false)
        XCTAssertEqual(account1.isWritable, true)
        
        let account2 = accountKeys[2]
        XCTAssertEqual(account2.publicKey.base58EncodedString, "BvKyAQNCsgWC7XDXKAGEeUyumKJXcmBEfLEYxaapqASZ")
        XCTAssertEqual(account2.isSigner, false)
        XCTAssertEqual(account2.isWritable, true)
        
        let account3 = accountKeys[3]
        XCTAssertEqual(account3.publicKey.base58EncodedString, "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA")
        XCTAssertEqual(account3.isSigner, false)
        XCTAssertEqual(account3.isWritable, false)
    }
    
    func testCloseToken() throws {
        
    }

}
