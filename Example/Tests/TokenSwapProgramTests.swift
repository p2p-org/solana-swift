//
//  TokenSwapProgramTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 20/01/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import SolanaSwift

class TokenSwapProgramTests: XCTestCase {
    let publicKey = try! SolanaSDK.PublicKey(string: "11111111111111111111111111111111")
    
    //    override func setUpWithError() throws {
    //        // Put setup code here. This method is called before the invocation of each test method in the class.
    //
    //        // In UI tests it is usually best to stop immediately when a failure occurs.
    //        continueAfterFailure = false
    //
    //        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    //        XCUIApplication().launch()
    //
    //        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    //    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testDecodingSwapData() throws {
        let string = #"["Af8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAJtI5Id8QBhfDU9HbNjlM8tWzr5NFhnaIL7zaMrcQO6xAAMAAAAAAAAA6AMAAAAAAAABAAAAAAAAAOgDAAAAAAAAAAAAAAAAAAA=", "base64"]"#
        
        let publicKey = try SolanaSDK.PublicKey(string: "11111111111111111111111111111111")
        
        let info = try JSONDecoder().decode(SolanaSDK.Buffer<SolanaSDK.TokenSwapInfo>.self, from: string.data(using: .utf8)!)
        
        XCTAssertTrue(info.value?.isInitialized == true)
        XCTAssertEqual(255, info.value?.nonce)
        XCTAssertEqual(publicKey, info.value?.tokenProgramId)
        XCTAssertEqual(publicKey, info.value?.tokenAccountA)
        XCTAssertEqual(publicKey, info.value?.tokenAccountB)
        XCTAssertEqual(publicKey, info.value?.tokenPool)
        XCTAssertEqual(publicKey, info.value?.mintA)
        XCTAssertEqual(publicKey, info.value?.mintB)
        XCTAssertEqual(publicKey, info.value?.feeAccount)
        XCTAssertEqual(155, info.value?.curveType)
        XCTAssertEqual(963515510526829640, info.value?.tradeFeeNumerator)
        XCTAssertEqual(6254149569805567823, info.value?.tradeFeeDenominator)
        XCTAssertEqual(13700189867744280270, info.value?.ownerTradeFeeNumerator)
        XCTAssertEqual(50083033227356403, info.value?.ownerTradeFeeDenominator)
        XCTAssertEqual(3, info.value?.ownerWithdrawFeeNumerator)
        XCTAssertEqual(1000, info.value?.ownerWithdrawFeeDenominator)
        XCTAssertEqual(1, info.value?.hostFeeNumerator)
        XCTAssertEqual(1000, info.value?.hostFeeDenominator)
    }
    
    func testSwapInstruction() throws {
        let instruction = SolanaSDK.TokenSwapProgram.swapInstruction(
            tokenSwapAccount: publicKey,
            authority: publicKey,
            userSource: publicKey,
            poolSource: publicKey,
            poolDestination: publicKey,
            userDestination: publicKey,
            poolMint: publicKey,
            feeAccount: publicKey,
            hostFeeAccount: publicKey,
            tokenProgramId: publicKey,
            swapProgramId: publicKey,
            amountIn: 100000,
            minimumAmountOut: 0
        )
        
        XCTAssertEqual(Base58.decode("tSBHVn49GSCW4DNB1EYv9M"), instruction.data)
    }
    
    func testDepositInstruction() throws {
        let instruction = SolanaSDK.TokenSwapProgram.depositInstruction(
            tokenSwap: publicKey,
            authority: publicKey,
            sourceA: publicKey,
            sourceB: publicKey,
            intoA: publicKey,
            intoB: publicKey,
            poolToken: publicKey,
            poolAccount: publicKey,
            tokenProgramId: publicKey,
            swapProgramId: publicKey,
            poolTokenAmount: 507788,
            maximumTokenA: 51,
            maximumTokenB: 1038
        )
        
        XCTAssertEqual(Base58.decode("22WQQtPPUknk68tx2dUGRL1Q4Vj2mkg6Hd"), instruction.data)
    }
    
    func testWithdrawInstruction() throws {
        let instruction = SolanaSDK.TokenSwapProgram.withdrawInstruction(
            tokenSwap: publicKey,
            authority: publicKey,
            poolMint: publicKey,
            feeAccount: publicKey,
            sourcePoolAccount: publicKey,
            fromA: publicKey,
            fromB: publicKey,
            userAccountA: publicKey,
            userAccountB: publicKey,
            swapProgramId: publicKey,
            tokenProgramId: publicKey,
            poolTokenAmount: 498409,
            minimumTokenA: 49,
            minimumTokenB: 979
        )
        
        XCTAssertEqual(Base58.decode("2aJyv2ixHWcYWoAKJkYMzSPwTrGUfnSR9R"), instruction.data)
    }
}
