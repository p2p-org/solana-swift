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
    override var notificationHandler: OrcaSwapSignatureNotificationHandler {
        socket
    }
    
    var solPubkey: String {
        solanaSDK.accountStorage.account!.publicKey.base58EncodedString
    }
    
    override var endpoint: SolanaSDK.APIEndPoint! {
        .init(url: "https://solana-api.projectserum.com", network: .mainnetBeta)
    }
    
    override var phrase: String {
        secretPhrase
    }
    
    override func setUpWithError() throws {
        socket = SolanaSDK.Socket(endpoint: endpoint.socketUrl)
        try super.setUpWithError()
    }
    
    // MARK: - Transitive SOL to SPL
    func testTransitiveSwapSOLToCreatedSPL() throws {
        let amount: Double = 0.01 // 0.001 SOL to created KURO
        
        let swapSimulation = orcaSwap.swap(
            fromWalletPubkey: solPubkey,
            toWalletPubkey: kuroPubkey,
            bestPoolsPair: [solUSDCAquafarmsPool, usdcKUROAquafarmsPool],
            amount: amount,
            slippage: 0.05,
            isSimulation: true
        )
        
        XCTAssertNoThrow(try swapSimulation.toBlocking().first())
    }
    
    func testTransitiveSwapSOLToUncreatedSPL() throws {
        socket.connect()
        
        let amount: Double = 0.001 // 0.001 SOL to created USDC

        let swapSimulation = orcaSwap.swap(
            fromWalletPubkey: solPubkey,
            toWalletPubkey: nil,
            bestPoolsPair: [solUSDCAquafarmsPool, usdcSLIMAquafarmsPool],
            amount: amount,
            slippage: 0.05,
            isSimulation: false
        )

        XCTAssertNoThrow(try swapSimulation.toBlocking().first())
        
        socket.disconnect()
    }
}
