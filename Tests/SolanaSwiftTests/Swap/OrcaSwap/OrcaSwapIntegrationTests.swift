//
//  File.swift
//  
//
//  Created by Chung Tran on 18/10/2021.
//

import Foundation
import XCTest
@testable import SolanaSwift

private let socnPubkey = "64DzCPdUpQUTnSgY6hP6ux125vY2v3aWbE4T4G42SM1j"
private let solPubkey = "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"
private let usdcPubkey = "3uetDDizgTtadDHZzyy9BqxrjQcozMEkxzbKhfZF4tG3"

class OrcaSwapIntegrationTests: XCTestCase {
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
    
    // MARK: - Direct SOL to SPL
    func testDirectSwapSOLToCreatedSPL() throws {
        let amount: Double = 0.001 // 0.001 SOL to created SOCN
        
        let swapSimulation = orcaSwap.swap(
            fromWalletPubkey: solPubkey,
            toWalletPubkey: socnPubkey,
            bestPoolsPair: [socnSOLStableAquafarmsPool.reversed],
            amount: amount,
            slippage: 0.005,
            isSimulation: true
        )
        
        XCTAssertNoThrow(try swapSimulation.toBlocking().first())
    }
    
    func testDirectSwapSOLToUncreatedSPL() throws {
        let amount: Double = 0.001 // 0.001 SOL to uncreated
        
        let swapSimulation = orcaSwap.swap(
            fromWalletPubkey: solPubkey,
            toWalletPubkey: nil,
            bestPoolsPair: [solNinjaAquafarmsPool],
            amount: amount,
            slippage: 0.005,
            isSimulation: true
        )
        
        XCTAssertNoThrow(try swapSimulation.toBlocking().first())
    }
    
    // MARK: - Direct SPL to SOL
    func testDirectSwapSPLToSOL() throws {
        let amount: Double = 0.001 // 0.001 SOCN to Native SOL
        
        let swapSimulation = orcaSwap.swap(
            fromWalletPubkey: socnPubkey,
            toWalletPubkey: solPubkey,
            bestPoolsPair: [socnSOLStableAquafarmsPool],
            amount: amount,
            slippage: 0.005,
            isSimulation: true
        )
        
        XCTAssertNoThrow(try swapSimulation.toBlocking().first())
    }
    
    // MARK: - Direct SPL to SPL
    func testDirectSwapSPLToCreatedSPL() throws {
        let amount: Double = 0.001 // 0.001 SOCN to USDC
        
        let swapSimulation = orcaSwap.swap(
            fromWalletPubkey: socnPubkey,
            toWalletPubkey: usdcPubkey,
            bestPoolsPair: [socnUSDCAquafarmsPool],
            amount: amount,
            slippage: 0.005,
            isSimulation: true
        )
        
        XCTAssertNoThrow(try swapSimulation.toBlocking().first())
    }
    
    func testDirectSwapSPLToUncreatedSPL() throws {
        let amount: Double = 0.1 // 0.1 USDC to MNGO
        
        let swapSimulation = orcaSwap.swap(
            fromWalletPubkey: usdcPubkey,
            toWalletPubkey: nil,
            bestPoolsPair: [usdcMNGOAquafarmsPool],
            amount: amount,
            slippage: 0.005,
            isSimulation: true
        )
        
        XCTAssertNoThrow(try swapSimulation.toBlocking().first())
    }
}

