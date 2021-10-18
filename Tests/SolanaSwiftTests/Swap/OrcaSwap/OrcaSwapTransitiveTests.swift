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
    var socket: SolanaSDK.Socket!
    
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
        
        socket = SolanaSDK.Socket(endpoint: endpoint.socketUrl)
        
        orcaSwap = OrcaSwap(
            apiClient: OrcaSwap.MockAPIClient(network: "mainnet"),
            solanaClient: solanaSDK,
            accountProvider: solanaSDK,
            notificationHandler: socket
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
            slippage: 0.05,
            isSimulation: true
        )
        
        XCTAssertNoThrow(try swapSimulation.toBlocking().first())
    }
    
    func testTransitiveSwapSOLToUncreatedSPL() throws {
        socket.connect()
        
        let amount: Double = 0.01 // 0.001 SOL to uncreated KURO
        
        let swapSimulation = orcaSwap.swap(
            fromWalletPubkey: OrcaSwap.solPubkey,
            toWalletPubkey: nil,
            bestPoolsPair: [OrcaSwap.solUSDCAquafarmsPool, OrcaSwap.usdcKUROAquafarmsPool],
            amount: amount,
            slippage: 0.05,
            isSimulation: true
        )
        
        XCTAssertNoThrow(try swapSimulation.toBlocking().first())
        
        socket.disconnect()
    }
}
