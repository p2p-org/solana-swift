//
//  File.swift
//  
//
//  Created by Chung Tran on 18/10/2021.
//

import Foundation
import XCTest
@testable import SolanaSwift

class OrcaSwapTransitiveTests: XCTestCase {
    var solanaSDK: SolanaSDK!
    var orcaSwap: OrcaSwap!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        let accountStorage = InMemoryAccountStorage()
        
        let endpoint = SolanaSDK.APIEndPoint(url: "https://p2p.rpcpool.com/", network: .mainnetBeta)
        
        solanaSDK = SolanaSDK(
            endpoint: endpoint,
            accountStorage: accountStorage
        )
        
        let account = try SolanaSDK.Account(
            phrase: "miracle pizza supply useful steak border same again youth silver access hundred".components(separatedBy: " "),
            network: endpoint.network
        )
        try accountStorage.save(account)
        
        orcaSwap = OrcaSwap(
            apiClient: OrcaSwap.MockAPIClient(network: "mainnet"),
            solanaClient: solanaSDK,
            accountProvider: solanaSDK
        )
        
        _ = orcaSwap.load().toBlocking().materialize()
    }
    
    // MARK: - Transitive SOL to SPL
    func testTransitiveSwapSOLToCreatedSPL() throws {
        let amount: Double = 0.001 // 0.001 SOL to created SLIM
        
        let swapSimulation = orcaSwap.swap(
            fromWalletPubkey: OrcaSwap.solPubkey,
            toWalletPubkey: OrcaSwap.slimPubkey,
            bestPoolsPair: [OrcaSwap.solUSDCAquafarmsPool, OrcaSwap.usdcSLIMAquafarmsPool],
            amount: amount,
            slippage: 0.005,
            isSimulation: true
        )
        
        XCTAssertNoThrow(try swapSimulation.toBlocking().first())
    }
}
