//
//  File.swift
//  
//
//  Created by Chung Tran on 18/10/2021.
//

import Foundation
import XCTest
@testable import SolanaSwift

class OrcaSwapIntegrationTests: XCTestCase {
    let solanaSDK = SolanaSDK(
        endpoint: .init(url: "https://p2p.rpcpool.com/", network: .mainnetBeta),
        accountStorage: InMemoryAccountStorage()
    )
    
    private lazy var orcaSwap = OrcaSwap(
        apiClient: OrcaSwap.MockAPIClient(network: "mainnet"),
        solanaClient: solanaSDK,
        accountProvider: solanaSDK
    )
}
