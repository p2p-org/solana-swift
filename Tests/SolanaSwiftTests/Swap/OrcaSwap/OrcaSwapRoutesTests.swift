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
        Logger.log(message: routes.jsonString!, event: .info)
        XCTAssertNotEqual(routes.count, 0)
    }
}
