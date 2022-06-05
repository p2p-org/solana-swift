//
//  APIClientTests.swift
//  
//
//  Created by Chung Tran on 05/06/2022.
//

import XCTest
import SolanaSwift

class APIClientTests: XCTestCase {

    private let apiClient = JSONRPCAPIClient(endpoint: .init(address: "https://api.devnet.solana.com", network: .devnet))

    func testGenericRequest() async throws {
        let result: String = try await apiClient.request(method: "getHealth")
        XCTAssertEqual(result, "ok")
    }

}
