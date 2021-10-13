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
    
    func testFindRoutes() throws {
        let routes = try orcaSwap.findRoutes().toBlocking().first()!
//        print(routes.jsonString!.replacingOccurrences(of: #"\/"#, with: "/"))
        XCTAssertNotEqual(routes.count, 0)
    }
}
