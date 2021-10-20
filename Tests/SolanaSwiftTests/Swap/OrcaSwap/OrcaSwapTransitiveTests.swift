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
    var solPubkey: String {
        solanaSDK.accountStorage.account!.publicKey.base58EncodedString
    }
    
    override var endpoint: SolanaSDK.APIEndPoint! {
        .init(url: "https://solana-api.projectserum.com", network: .mainnetBeta)
    }
    
    override var phrase: String {
        secretPhrase
    }
    
    // MARK: - Transitive SOL to SPL
    func testTransitiveSwapSOLToCreatedSPL() throws {
        let amount: Double = 0.01 // 0.001 SOL to created KURO
        
        let pools = [
            poolsRepository["SOL/USDC[aquafarm]"]!,
            poolsRepository["KURO/USDC[aquafarm]"]!.reversed
        ]
        
        let swapSimulation = try fillPoolsBalancesAndSwap(
            fromWalletPubkey: solPubkey,
            toWalletPubkey: kuroPubkey,
            bestPoolsPair: pools,
            amount: amount,
            slippage: 0.5,
            isSimulation: true
        )
        
        XCTAssertNoThrow(try swapSimulation.toBlocking().first())
    }
    
    func testTransitiveSwapSOLToUncreatedSPL() throws {
        let amount: Double = 0.001 // 0.001 SOL to created USDC
        
        let pools = [
            poolsRepository["SOL/USDC[aquafarm]"]!,
            poolsRepository["ABR/USDC[aquafarm]"]!.reversed
        ]

        let swapSimulation = try fillPoolsBalancesAndSwap(
            fromWalletPubkey: solPubkey,
            toWalletPubkey: nil,
            bestPoolsPair: pools,
            amount: amount,
            slippage: 0.5,
            isSimulation: true
        )

        XCTAssertNoThrow(try swapSimulation.toBlocking().first())
    }
    
    // MARK: - Transitive SPL to SPL
    func testTransitiveSwapSPLToCreatedSPL() throws {
        let amount: Double = 0.01 // 0.01 SLIM to KURO
        
        let pools = [
            poolsRepository["SLIM/USDC[aquafarm]"]!,
            poolsRepository["KURO/USDC[aquafarm]"]!.reversed
        ]
        
        let swapSimulation = try fillPoolsBalancesAndSwap(
            fromWalletPubkey: slimPubkey,
            toWalletPubkey: kuroPubkey,
            bestPoolsPair: pools,
            amount: amount,
            slippage: 0.5,
            isSimulation: true
        )
        
        XCTAssertNoThrow(try swapSimulation.toBlocking().first())
    }
    
    func testTransitiveSwapSPLToUncreatedSPL() throws {
        let amount: Double = 0.01 // 0.01 SLIM to ABR
        
        let pools = [
            poolsRepository["SLIM/USDC[aquafarm]"]!,
            poolsRepository["ABR/USDC[aquafarm]"]!.reversed
        ]
        
        let swapSimulation = try fillPoolsBalancesAndSwap(
            fromWalletPubkey: slimPubkey,
            toWalletPubkey: nil,
            bestPoolsPair: pools,
            amount: amount,
            slippage: 0.05,
            isSimulation: true
        )
        
        XCTAssertNoThrow(try swapSimulation.toBlocking().first())
    }
}
