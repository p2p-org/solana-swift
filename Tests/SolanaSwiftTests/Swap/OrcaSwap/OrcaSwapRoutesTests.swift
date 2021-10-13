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
    let orcaSwap = OrcaSwap(apiClient: OrcaSwap.MockAPIClient(network: "mainnet"))
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
}
