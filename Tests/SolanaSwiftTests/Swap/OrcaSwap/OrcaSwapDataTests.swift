//
//  File.swift
//  
//
//  Created by Chung Tran on 13/10/2021.
//

import Foundation

import Foundation
import XCTest
import RxBlocking
@testable import SolanaSwift

class OrcaSwapDataTests: XCTestCase {
    func testRetrievingDatas() throws {
        let tokens = try OrcaSwap.getTokens(network: "mainnet-beta").toBlocking().first()
        XCTAssertNotNil(tokens)
        
    }
}
