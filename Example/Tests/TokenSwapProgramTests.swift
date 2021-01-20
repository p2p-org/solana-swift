//
//  TokenSwapProgramTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 20/01/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import SolanaSwift
import BigInt

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
            amountIn: BigInt(100000),
            minimumAmountOut: BigInt(0)
        )
        
        XCTAssertEqual(Base58.decode("tSBHVn49GSCW4DNB1EYv9M"), instruction.data)
    }

}
