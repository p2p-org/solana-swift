//
//  SerumSwapMarketTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 18/08/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
@testable import SolanaSwift

class SerumSwapMarketTests: SerumSwapTests {
    override var overridingAccount: String? {
        "matter outer client aspect pear cigar caution robust easily merge dwarf wide short sail unusual indicate roast giraffe clay meat crowd exile curious vibrant"
    }
    
    func testGetMarket() throws {
        // Swaps SRM -> USDC on the Serum orderbook.
        let marketAddresses = try serumSwap.route(fromMint: SRM, toMint: USDC).toBlocking().first()!!
        let marketAddress = marketAddresses[0]
        let market = try serumSwap.loadMarket(address: marketAddress).toBlocking().first()
        XCTAssertNotNil(market)
    }
    
    func testGetPriceFromCachedMarket() throws {
        let srmUSDCPair = try SRMUSDCMarket.loadOrderbook(client: serumSwap.client).toBlocking().first()
        XCTAssertNotNil(srmUSDCPair)
        
        let srmBbo = srmUSDCPair!.bbo
        
        let btcUSDCPair = try BTCUSDCMarket.loadOrderbook(client: serumSwap.client).toBlocking().first()
        XCTAssertNotNil(btcUSDCPair)
        
        let btcBbo = btcUSDCPair!.bbo
        print(srmBbo!)
        print(btcBbo!)
    }
    
    func testGetMinOrderSizeFromCachedMarket() throws {
        let minOrderSize = try serumSwap.loadMinOrderSize(fromMint: SOL.base58EncodedString, toMint: USDC.base58EncodedString).toBlocking().first()
        XCTAssertEqual(minOrderSize, 0.1)
    }
    
    func testCalculateExchangeRate() throws {
        let fair: Double = 0.11853959222380275
        let expectedRate: UInt64 = 8375352
        let realRate = serumSwap.calculateExchangeRate(
            fair: fair,
            slippage: 0.005,
            toDecimal: 6
        )
        XCTAssertEqual(expectedRate, realRate)
    }
    
    func testCalculateNetworkFees() throws {
        let lps: UInt64 = 5000
        let mre: UInt64 = 2039280
        
        // from native sol to new usdt wallet
        let newUSDTWallet = SolanaSDK.Wallet(
            pubkey: nil,
            lamports: nil,
            token: .init(
                _tags: nil,
                chainId: 101,
                address: USDT.base58EncodedString,
                symbol: "USDT",
                name: "USDT",
                decimals: 6,
                logoURI: nil,
                extensions: nil
            )
        )
        let networkFees = try serumSwap.calculateNetworkFee(
            fromWallet: solNativeWallet,
            toWallet: newUSDTWallet,
            lamportsPerSignature: lps,
            minRentExemption: mre
        ).toBlocking().first()
        
        print(networkFees)
        
//        XCTAssertEqual(networkFees, 27451320)
        
        // from usdt to srm
        let newSRMWallet = SolanaSDK.Wallet(
            pubkey: nil,
            lamports: nil,
            token: .init(
                _tags: nil,
                chainId: 101,
                address: SRM.base58EncodedString,
                symbol: "SRM",
                name: "Serum",
                decimals: 6,
                logoURI: nil,
                extensions: nil
            )
        )
        let networkFees2 = try serumSwap.calculateNetworkFee(
            fromWallet: newUSDTWallet,
            toWallet: newSRMWallet,
            lamportsPerSignature: lps,
            minRentExemption: mre
        ).toBlocking().first()
        
        print(networkFees2)
        
//        XCTAssertEqual(networkFees2, 25407040)
    }
}
