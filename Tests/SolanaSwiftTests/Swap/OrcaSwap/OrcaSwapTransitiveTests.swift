//
//  File.swift
//  
//
//  Created by Chung Tran on 18/10/2021.
//

import Foundation
import XCTest
@testable import SolanaSwift

class OrcaSwapTransitiveTests: OrcaSwapSwapTests {
    var socket: SolanaSDK.Socket!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        socket = SolanaSDK.Socket(endpoint: endpoint.socketUrl)
    }
    
    // MARK: - Transitive SOL to SPL
    func testTransitiveSwapSOLToCreatedSPL() throws {
        let amount: Double = 0.001 // 0.001 SOL to created SLIM
        
        let swapSimulation = orcaSwap.swap(
            fromWalletPubkey: solPubkey,
            toWalletPubkey: slimPubkey,
            bestPoolsPair: [solUSDCAquafarmsPool, usdcSLIMAquafarmsPool],
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
            fromWalletPubkey: solPubkey,
            toWalletPubkey: nil,
            bestPoolsPair: [solUSDCAquafarmsPool, usdcKUROAquafarmsPool],
            amount: amount,
            slippage: 0.05,
            isSimulation: true
        )
        
        XCTAssertNoThrow(try swapSimulation.toBlocking().first())
        
        socket.disconnect()
    }
}
