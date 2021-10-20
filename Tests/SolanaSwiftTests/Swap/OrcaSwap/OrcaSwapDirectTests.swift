//
//  File.swift
//  
//
//  Created by Chung Tran on 18/10/2021.
//

import Foundation
import XCTest
@testable import SolanaSwift

class OrcaSwapDirectTests: OrcaSwapSwapTests {
    let socnPubkey = "64DzCPdUpQUTnSgY6hP6ux125vY2v3aWbE4T4G42SM1j"
    let solPubkey = "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"
    let usdcPubkey = "3uetDDizgTtadDHZzyy9BqxrjQcozMEkxzbKhfZF4tG3"
    let slimPubkey = "ECHvg7FdfakbKQpeStwh1K3iU6XwfBQWMNrH7rUAQkN7"
    
    // MARK: - Direct SOL to SPL
    func testDirectSwapSOLToCreatedSPL() throws {
        let amount: Double = 0.001 // 0.001 SOL to created SOCN
        
        let pool = poolsRepository["SOCN/SOL[stable][aquafarm]"]!.reversed
        
        let swapSimulation = try fillPoolsBalancesAndSwap(
            fromWalletPubkey: solPubkey,
            toWalletPubkey: socnPubkey,
            bestPoolsPair: [pool],
            amount: amount,
            slippage: 0.05,
            isSimulation: true
        )
        
        XCTAssertNoThrow(try swapSimulation.toBlocking().first())
    }
    
    func testDirectSwapSOLToUncreatedSPL() throws {
        let amount: Double = 0.001 // 0.001 SOL to uncreated
        
        let pool = poolsRepository["NINJA/SOL[aquafarm]"]!.reversed
        
        let swapSimulation = try fillPoolsBalancesAndSwap(
            fromWalletPubkey: solPubkey,
            toWalletPubkey: nil,
            bestPoolsPair: [pool],
            amount: amount,
            slippage: 0.05,
            isSimulation: true
        )
        
        XCTAssertNoThrow(try swapSimulation.toBlocking().first())
    }
    
    // MARK: - Direct SPL to SOL
    func testDirectSwapSPLToSOL() throws {
        let amount: Double = 0.001 // 0.001 SOCN to Native SOL
        
        let pool = poolsRepository["SOCN/SOL[stable][aquafarm]"]!
        
        let swapSimulation = try fillPoolsBalancesAndSwap(
            fromWalletPubkey: socnPubkey,
            toWalletPubkey: solPubkey,
            bestPoolsPair: [pool],
            amount: amount,
            slippage: 0.05,
            isSimulation: true
        )
        
        XCTAssertNoThrow(try swapSimulation.toBlocking().first())
    }
    
    // MARK: - Direct SPL to SPL
    func testDirectSwapSPLToCreatedSPL() throws {
        let amount: Double = 0.001 // 0.001 SOCN to USDC
        
        let pool = poolsRepository["SOCN/USDC[aquafarm]"]!
        
        let swapSimulation = try fillPoolsBalancesAndSwap(
            fromWalletPubkey: socnPubkey,
            toWalletPubkey: usdcPubkey,
            bestPoolsPair: [pool],
            amount: amount,
            slippage: 0.5,
            isSimulation: true
        )
        
        XCTAssertNoThrow(try swapSimulation.toBlocking().first())
    }
    
    func testDirectSwapSPLToUncreatedSPL() throws {
        let amount: Double = 0.1 // 0.1 USDC to MNGO
        
        let pool = poolsRepository["MNGO/USDC[aquafarm]"]!.reversed
        
        let swapSimulation = try fillPoolsBalancesAndSwap(
            fromWalletPubkey: usdcPubkey,
            toWalletPubkey: nil,
            bestPoolsPair: [pool],
            amount: amount,
            slippage: 0.5,
            isSimulation: true
        )
        
        XCTAssertNoThrow(try swapSimulation.toBlocking().first())
    }
}

