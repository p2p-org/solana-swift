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
        let swapSimulation = try fillPoolsBalancesAndSwap(
            fromWalletPubkey: solPubkey,
            toWalletPubkey: socnPubkey,
            bestPoolsPair: [.init(name: "SOCN/SOL[stable][aquafarm]", reversed: true)],
            amount: 0.001,
            slippage: 0.05,
            isSimulation: true
        )
        
        XCTAssertNoThrow(try swapSimulation.toBlocking().first())
    }
    
    func testDirectSwapSOLToUncreatedSPL() throws {
        let swapSimulation = try fillPoolsBalancesAndSwap(
            fromWalletPubkey: solPubkey,
            toWalletPubkey: nil,
            bestPoolsPair: [.init(name: "NINJA/SOL[aquafarm]", reversed: true)],
            amount: 0.001,
            slippage: 0.05,
            isSimulation: true
        )
        
        XCTAssertNoThrow(try swapSimulation.toBlocking().first())
    }
    
    // MARK: - Direct SPL to SOL
    func testDirectSwapSPLToSOL() throws {
        let swapSimulation = try fillPoolsBalancesAndSwap(
            fromWalletPubkey: socnPubkey,
            toWalletPubkey: solPubkey,
            bestPoolsPair: [.init(name: "SOCN/SOL[stable][aquafarm]")],
            amount: 0.001,
            slippage: 0.05,
            isSimulation: true
        )
        
        XCTAssertNoThrow(try swapSimulation.toBlocking().first())
    }
    
    // MARK: - Direct SPL to SPL
    func testDirectSwapSPLToCreatedSPL() throws {
        let swapSimulation = try fillPoolsBalancesAndSwap(
            fromWalletPubkey: socnPubkey,
            toWalletPubkey: usdcPubkey,
            bestPoolsPair: [.init(name: "SOCN/USDC[aquafarm]")],
            amount: 0.01,
            slippage: 0.5,
            isSimulation: true
        )
        
        XCTAssertNoThrow(try swapSimulation.toBlocking().first())
    }
    
    func testDirectSwapSPLToUncreatedSPL() throws {
        let swapSimulation = try fillPoolsBalancesAndSwap(
            fromWalletPubkey: usdcPubkey,
            toWalletPubkey: nil,
            bestPoolsPair: [.init(name: "MNGO/USDC[aquafarm]", reversed: true)],
            amount: 0.1,
            slippage: 0.5,
            isSimulation: true
        )
        
        XCTAssertNoThrow(try swapSimulation.toBlocking().first())
    }
}

