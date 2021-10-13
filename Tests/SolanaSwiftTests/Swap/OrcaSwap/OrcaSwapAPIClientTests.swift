//
//  OrcaSwapAPIClientTests.swift
//  
//
//  Created by Chung Tran on 13/10/2021.
//

import Foundation

import Foundation
import XCTest
import RxBlocking
@testable import SolanaSwift

class OrcaSwapAPIClientTests: XCTestCase {
    private let client = OrcaSwap.APIClient(network: "mainnet-beta")
    
    func testRetrievingTokens() throws {
        let tokens = try client.getTokens().toBlocking().first()
        XCTAssertNotEqual(tokens?.count, 0)
    }
    
    func testRetrievingAquafarms() throws {
        let aquafarms = try client.getAquafarms().toBlocking().first()
        XCTAssertNotEqual(aquafarms?.count, 0)
    }
    
    func testRetrievingPools() throws {
        let pools = try client.getPools().toBlocking().first()
        XCTAssertNotEqual(pools?.count, 0)
    }
}
