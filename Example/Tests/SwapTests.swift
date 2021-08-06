//
//  SwapTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 22/07/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
@testable import SolanaSwift

//class SwapTests: XCTestCase {
//    var endpoint: SolanaSDK.APIEndPoint {
//        .init(
//            url: "https://api.mainnet-beta.solana.com",
//            network: .mainnetBeta
//        )
//    }
//    var solanaSDK: SolanaSDK!
//    var account: SolanaSDK.Account {solanaSDK.accountStorage.account!}
//    
//    let ethMint = try! SolanaSDK.PublicKey(string: "2FPyTwcZLUg1MDrwsyoP4D6s1tM7hAkHYRjkNb5w6Pxk")
//    let solMint = try! SolanaSDK.PublicKey(string: "So11111111111111111111111111111111111111112")
//    
//    var ethToSOLPool: SolanaSDK.Pool!
//    var solToETHPool: SolanaSDK.Pool { ethToSOLPool.reversedPool }
//
//    override func setUpWithError() throws {
//        let accountStorage = InMemoryAccountStorage()
//        solanaSDK = SolanaSDK(endpoint: endpoint, accountStorage: accountStorage)
//        let account = try SolanaSDK.Account(phrase: "miracle pizza supply useful steak border same again youth silver access hundred".components(separatedBy: " "), network: endpoint.network, derivablePath: .init(type: .deprecated, walletIndex: 0))
//        try accountStorage.save(account)
//        
//        ethToSOLPool = try solanaSDK.getMatchedPool(sourceMint: ethMint, destinationMint: solMint).toBlocking().first()
//    }
//    
//    func testGetMatchedPool() throws {
//        let sourceMint = try SolanaSDK.PublicKey(string: "2FPyTwcZLUg1MDrwsyoP4D6s1tM7hAkHYRjkNb5w6Pxk")
//        let destinationMint = try SolanaSDK.PublicKey(string: "So11111111111111111111111111111111111111112")
//        let pool = try solanaSDK.getMatchedPool(sourceMint: sourceMint, destinationMint: destinationMint).toBlocking().first()
//        XCTAssertEqual(pool?.swapData.mintA, sourceMint)
//        XCTAssertEqual(pool?.swapData.mintB, destinationMint)
//    }
//    
//    func testSwapETHToSOL() throws {
//        let source = try SolanaSDK.PublicKey(string: "4Tz8MH5APRfA4rjUNxhRruqGGMNvrgji3KhWYKf54dc7")
//        let destination = account.publicKey
//        let ethAmount: SolanaSDK.Lamports = 1
//        
//        let sourceAccountInstructions = try solanaSDK.prepareSourceAccountAndInstructions(pool: ethToSOLPool, source: source, amount: ethAmount, feePayer: account.publicKey).toBlocking().first()
//        XCTAssertEqual(sourceAccountInstructions?.account, source)
//        XCTAssertEqual(sourceAccountInstructions?.instructions.count, 0)
//        XCTAssertEqual(sourceAccountInstructions?.cleanupInstructions.count, 0)
//        XCTAssertEqual(sourceAccountInstructions?.signers.count, 0)
//        
//        let destinationAccountInstructions = try solanaSDK.prepareDestinationAccountAndInstructions(myAccount: account.publicKey, destination: destination, destinationMint: solMint, feePayer: account.publicKey).toBlocking().first()
//        XCTAssertEqual(destinationAccountInstructions?.account.base58EncodedString, "2qoruNhk16M38BS95qs6DoTvHDnEx2ePLNKaPYnuwxne")
//        XCTAssertEqual(destinationAccountInstructions?.instructions.count, 0)
//        XCTAssertEqual(destinationAccountInstructions?.cleanupInstructions.count, 1)
//        XCTAssertEqual(destinationAccountInstructions?.signers.count, 0)
//    }
//}
