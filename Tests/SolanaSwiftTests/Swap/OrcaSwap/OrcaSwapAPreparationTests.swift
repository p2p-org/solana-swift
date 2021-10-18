//
//  OrcaSwapPreparationTests.swift
//  
//
//  Created by Chung Tran on 13/10/2021.
//

import Foundation
import XCTest
@testable import SolanaSwift

class OrcaSwapPreparationTests: XCTestCase {
    let orcaSwap = OrcaSwap(
        apiClient: OrcaSwap.MockAPIClient(network: "mainnet"),
        solanaClient: OrcaSwap.MockSolanaClient(),
        accountProvider: OrcaSwap.MockAccountProvider(),
        notificationHandler: OrcaSwap.MockSocket()
    )
    var swapInfo: OrcaSwap.SwapInfo {
        orcaSwap.info!
    }
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        _ = orcaSwap.load().toBlocking().materialize()
    }
    
    // MARK: - Swap data
    func testLoadSwap() throws {
//        print(routes.jsonString!.replacingOccurrences(of: #"\/"#, with: "/"))
        XCTAssertEqual(swapInfo.routes.count, 1035)
        XCTAssertEqual(swapInfo.tokens.count, 117)
        XCTAssertEqual(swapInfo.pools.count, 71)
        XCTAssertEqual(swapInfo.programIds.serumTokenSwap, "SwaPpA9LAaLfeLi3a68M4DjnLqgtticKg6CnyNwgAC8")
        XCTAssertEqual(swapInfo.programIds.tokenSwapV2, "9W959DqEETiGZocYWCQPaJ6sBmUzgfxXfqGeTEdp3aQP")
        XCTAssertEqual(swapInfo.programIds.tokenSwap, "DjVE6JNiYqPL2QXyCUUh8rNjHrbz9hXHNYt99MQ59qw1")
        XCTAssertEqual(swapInfo.programIds.token, "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA")
        XCTAssertEqual(swapInfo.programIds.aquafarm, "82yxjeMsvaURa4MbZZ7WZZHfobirZYkH1zF8fmeGtyaQ")
        XCTAssertEqual(swapInfo.tokenNames.count, 117)
    }
    
    // MARK: - Find destinations
    func testFindDestinations() throws {
        let routes = try orcaSwap.findPosibleDestinationMints(fromMint: OrcaSwap.btcMint)
        XCTAssertEqual(routes.count, 21)
    }
    
    // MARK: - BTC -> ETH
    // Order may change
//        [
//            [
//                "BTC/ETH"
//            ],
//            [
//                "BTC/SOL[aquafarm]",
//                "ETH/SOL"
//            ],
//            [
//                "BTC/SOL[aquafarm]",
//                "ETH/SOL[aquafarm]"
//            ]
//        ]
    func testGetTradablePoolsPairs() throws {
        let pools = try orcaSwap.getTradablePoolsPairs(fromMint: OrcaSwap.btcMint, toMint: OrcaSwap.ethMint).toBlocking().first()!
        XCTAssertEqual(pools.count, 3) //
        XCTAssertEqual(pools.flatMap { $0 }.count, 5)
        
        let btcETHPool = pools.first(where: {$0.count == 1})!.first!
        XCTAssertEqual(btcETHPool.tokenAccountA, "81w3VGbnszMKpUwh9EzAF9LpRzkKxc5XYCW64fuYk1jH")
        XCTAssertEqual(btcETHPool.tokenAccountB, "6r14WvGMaR1xGMnaU8JKeuDK38RvUNxJfoXtycUKtC7Z")
        XCTAssertEqual(btcETHPool.tokenAName, "BTC")
        XCTAssertEqual(btcETHPool.tokenBName, "ETH")
        
        let btcSOLAquafarm = pools.first(where: {$0.contains(where: {$0.account == "7N2AEJ98qBs4PwEwZ6k5pj8uZBKMkZrKZeiC7A64B47u"})})!.first!
        XCTAssertEqual(btcSOLAquafarm.tokenAccountA, "9G5TBPbEUg2iaFxJ29uVAT8ZzxY77esRshyHiLYZKRh8")
        XCTAssertEqual(btcSOLAquafarm.tokenAccountB, "5eqcnUasgU2NRrEAeWxvFVRTTYWJWfAJhsdffvc6nJc2")
        XCTAssertEqual(btcSOLAquafarm.tokenAName, "BTC")
        XCTAssertEqual(btcSOLAquafarm.tokenBName, "SOL")
        
        let ethSOL = pools.first(where: {$0.contains(where: {$0.account == "4vWJYxLx9F7WPQeeYzg9cxhDeaPjwruZXCffaSknWFxy"})})!.last! // Reversed to SOL/ETH
        XCTAssertEqual(ethSOL.tokenAccountA, "5x1amFuGMfUVzy49Y4Pc3HyCVD2usjLaofnzB3d8h7rv") // originalTokenAccountB
        XCTAssertEqual(ethSOL.tokenAccountB, "FidGus13X2HPzd3cuBEFSq32UcBQkF68niwvP6bM4fs2") // originalTokenAccountA
        XCTAssertEqual(ethSOL.tokenAName, "SOL")
        XCTAssertEqual(ethSOL.tokenBName, "ETH")
        
        let ethSOLAquafarm = pools.first(where: {$0.contains(where: {$0.account == "EuK3xDa4rWuHeMQCBsHf1ETZNiEQb5C476oE9u9kp8Ji"})})!.last! // reversed to SOL/ETH
        XCTAssertEqual(ethSOLAquafarm.tokenAccountA, "5pUTGvN2AA2BEzBDU4CNDh3LHER15WS6J8oJf5XeZFD8") // originalTokenAccountB
        XCTAssertEqual(ethSOLAquafarm.tokenAccountB, "7F2cLdio3i6CCJaypj9VfNDPW2DwT3vkDmZJDEfmxu6A") // originalTokenAccountA
        XCTAssertEqual(ethSOLAquafarm.tokenAName, "SOL")
        XCTAssertEqual(ethSOLAquafarm.tokenBName, "ETH")
    }
    
    func testGetBestPoolsPair() throws {
        // when user enter input amount = 0.1 BTC
        let inputAmount: UInt64 = 100000 // 0.1 BTC
        let poolsPairs = try orcaSwap.getTradablePoolsPairs(fromMint: OrcaSwap.btcMint, toMint: OrcaSwap.ethMint).toBlocking().first()!
        let bestPoolsPair = try orcaSwap.findBestPoolsPairForInputAmount(inputAmount, from: poolsPairs)
        let estimatedAmount = bestPoolsPair?.getOutputAmount(fromInputAmount: inputAmount)
        XCTAssertEqual(estimatedAmount, 1588996) // 1.588996 ETH
        
        // when user enter estimated amount that he wants to receive as 1.6 ETH
        let estimatedAmount2: UInt64 = 1600000
        let bestPoolsPair2 = try orcaSwap.findBestPoolForEstimatedAmount(estimatedAmount2, from: poolsPairs)
        let inputAmount2 = bestPoolsPair2?.getInputAmount(fromEstimatedAmount: estimatedAmount2)
        XCTAssertEqual(inputAmount2, 100697) // 0.100697 BTC
    }
    
    // MARK: - SOCN -> SOL -> BTC (Reversed)
    // SOCN -> BTC
//        [
//            [
//                "BTC/SOL[aquafarm]",
//                "SOCN/SOL[stable][aquafarm]"
//            ]
//        ]
    // Should be considered at
//        [
//            [
//                "SOCN/SOL[stable][aquafarm]",
//                "BTC/SOL[aquafarm]"
//            ]
//        ]
    func testGetTradablePoolsPairsReversed() throws {
        let poolsPair = try orcaSwap.getTradablePoolsPairs(fromMint: OrcaSwap.socnMint, toMint: OrcaSwap.btcMint).toBlocking().first()!.first!
        XCTAssertEqual(poolsPair.count, 2) // there is only 1 pair
        
        let socnSOL = poolsPair.first!
        XCTAssertEqual(socnSOL.tokenAccountA, "C8DRXUqxXtUgvgBR7BPAmy6tnRJYgVjG27VU44wWDMNV")
        XCTAssertEqual(socnSOL.tokenAccountB, "DzdxH5qJ68PiM1p5o6PbPLPpDj8m1ZshcaMFATcxDZix")
        XCTAssertEqual(socnSOL.tokenAName, "SOCN")
        XCTAssertEqual(socnSOL.tokenBName, "SOL")
        
        let solBTC = poolsPair.last!
        XCTAssertEqual(solBTC.tokenAccountA, "5eqcnUasgU2NRrEAeWxvFVRTTYWJWfAJhsdffvc6nJc2")
        XCTAssertEqual(solBTC.tokenAccountB, "9G5TBPbEUg2iaFxJ29uVAT8ZzxY77esRshyHiLYZKRh8")
        XCTAssertEqual(solBTC.tokenAName, "SOL")
        XCTAssertEqual(solBTC.tokenBName, "BTC")
    }
    
    func testGetBestPoolsPairReversed() throws {
        // when user enter input amount = 419.68 SOCN
        let inputAmount: UInt64 = 419680000000 // 419.68 SOCN
        let poolsPairs = try orcaSwap.getTradablePoolsPairs(fromMint: OrcaSwap.socnMint, toMint: OrcaSwap.btcMint).toBlocking().first()!
        let bestPoolsPair = try orcaSwap.findBestPoolsPairForInputAmount(inputAmount, from: poolsPairs)
        let estimatedAmount = bestPoolsPair?.getOutputAmount(fromInputAmount: inputAmount)
        XCTAssertEqual(estimatedAmount, 1013077) // 1.013077 BTC
        
        // when user enter estimated amount that he wants to receive as 1 BTC
        let estimatedAmount2: UInt64 = 1000000 // 1 BTC
        let bestPoolsPair2 = try orcaSwap.findBestPoolForEstimatedAmount(estimatedAmount2, from: poolsPairs)
        let inputAmount2 = bestPoolsPair2?.getInputAmount(fromEstimatedAmount: estimatedAmount2)
        XCTAssertEqual(inputAmount2, 413909257520) // 413.909257520 BTC
    }
}
