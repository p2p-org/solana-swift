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
        let srmUSDCPair = try serumSwap.loadOrderbook(market: SRMUSDCMarket).toBlocking().first()
        XCTAssertNotNil(srmUSDCPair)
        
        let srmBbo = serumSwap.loadBbo(orderbookPair: srmUSDCPair!)
        
        let btcUSDCPair = try serumSwap.loadOrderbook(market: BTCUSDCMarket).toBlocking().first()
        XCTAssertNotNil(btcUSDCPair)
        
        let btcBbo = serumSwap.loadBbo(orderbookPair: btcUSDCPair!)
        print(srmBbo!)
        print(btcBbo!)
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
        
        XCTAssertEqual(networkFees, 27451320)
        
        // from usdc to srm
        let usdcWallet = wallets.first(where: {$0.token.address == USDC.base58EncodedString})!
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
            fromWallet: usdcWallet,
            toWallet: newSRMWallet,
            lamportsPerSignature: lps,
            minRentExemption: mre
        ).toBlocking().first()
        
        XCTAssertEqual(networkFees2, 25407040)
    }
}
