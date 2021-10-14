//
//  File.swift
//  
//
//  Created by Chung Tran on 13/10/2021.
//

import Foundation
import XCTest
@testable import SolanaSwift

class OrcaSwapRoutesTests: XCTestCase {
    let orcaSwap = OrcaSwap(
        apiClient: OrcaSwap.MockAPIClient(network: "mainnet"),
        solanaClient: OrcaSwap.MockSolanaClient()
    )
    var swapInfo: OrcaSwap.SwapInfo!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        swapInfo = try orcaSwap.load().toBlocking().first()!
    }
    
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
    
    func testFindDestinations() throws {
        let routes = try orcaSwap.findPosibleDestinations(fromTokenName: "BTC")
        XCTAssertEqual(routes.count, 45)
    }
    
    func testGetPools() throws {
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
        
        let pools = try orcaSwap.getPools(fromTokenName: "BTC", toTokenName: "ETH").toBlocking().first()!
        XCTAssertEqual(pools.count, 3) //
        XCTAssertEqual(pools.flatMap { $0 }.count, 5)
        
        let btcETHPool = pools[0][0]
        XCTAssertEqual(btcETHPool.tokenAccountA, "81w3VGbnszMKpUwh9EzAF9LpRzkKxc5XYCW64fuYk1jH")
        XCTAssertEqual(btcETHPool.tokenAccountB, "6r14WvGMaR1xGMnaU8JKeuDK38RvUNxJfoXtycUKtC7Z")
        XCTAssertEqual(btcETHPool.tokenAName, "BTC")
        XCTAssertEqual(btcETHPool.tokenBName, "ETH")
        
        let btcSOLAquafarm = pools[1][0]
        XCTAssertEqual(btcSOLAquafarm.tokenAccountA, "9G5TBPbEUg2iaFxJ29uVAT8ZzxY77esRshyHiLYZKRh8")
        XCTAssertEqual(btcSOLAquafarm.tokenAccountB, "5eqcnUasgU2NRrEAeWxvFVRTTYWJWfAJhsdffvc6nJc2")
        XCTAssertEqual(btcSOLAquafarm.tokenAName, "BTC")
        XCTAssertEqual(btcSOLAquafarm.tokenBName, "SOL")
        
        let ethSOL = pools[1][1] // reversed to SOL/ETH
        XCTAssertEqual(ethSOL.tokenAccountA, "5x1amFuGMfUVzy49Y4Pc3HyCVD2usjLaofnzB3d8h7rv") // originalTokenAccountB
        XCTAssertEqual(ethSOL.tokenAccountB, "FidGus13X2HPzd3cuBEFSq32UcBQkF68niwvP6bM4fs2") // originalTokenAccountA
        XCTAssertEqual(ethSOL.tokenAName, "SOL")
        XCTAssertEqual(ethSOL.tokenBName, "ETH")
        
        let ethSOLAquafarm = pools[2][1] // reversed to SOL/ETH
        XCTAssertEqual(ethSOLAquafarm.tokenAccountA, "5pUTGvN2AA2BEzBDU4CNDh3LHER15WS6J8oJf5XeZFD8") // originalTokenAccountB
        XCTAssertEqual(ethSOLAquafarm.tokenAccountB, "7F2cLdio3i6CCJaypj9VfNDPW2DwT3vkDmZJDEfmxu6A") // originalTokenAccountA
        XCTAssertEqual(ethSOLAquafarm.tokenAName, "SOL")
        XCTAssertEqual(ethSOLAquafarm.tokenBName, "ETH")
    }
}
