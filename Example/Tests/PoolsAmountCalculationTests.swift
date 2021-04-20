//
//  PoolsAmountCalculationTests.swift
//  SolanaSwift_Tests
//
//  Created by Chung Tran on 20/04/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import XCTest
@testable import SolanaSwift

class PoolsAmountCalculationTests: XCTestCase {
    var pool: SolanaSDK.Pool!
    override func setUpWithError() throws {
        pool = SolanaSDK.Pool(
            address: try .init(string: "Gyae6L6312xxe6vUDci71DXp4EARaRc35Lwx7ScmbwpC"),
            tokenAInfo: .init(
                mintAuthorityOption: 0,
                mintAuthority: nil,
                supply: 0,
                decimals: 9,
                isInitialized: true,
                freezeAuthorityOption: 0,
                freezeAuthority: nil
            ),
            tokenBInfo: .init(
                mintAuthorityOption: 1,
                mintAuthority: try .init(string: "6krMGWgeqD4CySfMr94WcfcVbf2TrMzfshAk5DcZ7mbu"),
                supply: 4650000000,
                decimals: 6,
                isInitialized: true,
                freezeAuthorityOption: 0,
                freezeAuthority: nil
            ),
            poolTokenMint: .init(
                mintAuthorityOption: 1,
                mintAuthority: try .init(string: "2d2c9nBrvfnBCf6n1TBxo8k45ENksCszZWNpGas7Qvg6"),
                supply: 0,
                decimals: 8,
                isInitialized: true,
                freezeAuthorityOption: 0,
                freezeAuthority: nil
            ),
            swapData: .init(
                version: 1,
                isInitialized: true,
                nonce: 254,
                tokenProgramId: try .init(string: "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA"),
                tokenAccountA: try .init(string: "Cv875w5gSLTVhDexpweLZC87EpLP3tXYc4x9AnZSfZ5S"),
                tokenAccountB: try .init(string: "BcWXNkAxALTxcfdLnjaJGSFkcMYQrxeGqbVSq7fw1TVn"),
                tokenPool: try .init(string: "3Jg7acR1ZVCz33gMAiG5X7qesk5odUHmGmuZhkmpEJYK"),
                mintA: try .init(string: "So11111111111111111111111111111111111111112"),
                mintB: try .init(string: "9n4nbM75f5Ui33ZbPYXn59EwSgE8CGsHtAeTH5YFeJ9E"),
                feeAccount: try .init(string: "AE1rsvh7xgD2uNqSYp7KitcYuqpxrd3d3Y6mzVvZ2Nu"),
                tradeFeeNumerator: 25,
                tradeFeeDenominator: 10000,
                ownerTradeFeeNumerator: 5,
                ownerTradeFeeDenominator: 10000,
                ownerWithdrawFeeNumerator: 0,
                ownerWithdrawFeeDenominator: 0,
                hostFeeNumerator: 20,
                hostFeeDenominator: 100,
                curveType: 0,
                payer: try .init(string: "11111111111111111111111111111111")
            ),
            tokenABalance: .init(
                uiAmount: 0,
                amount: "0",
                decimals: 9,
                uiAmountString: "0"
            ),
            tokenBBalance: .init(
                uiAmount: 0,
                amount: "0",
                decimals: 6,
                uiAmountString: "0"
            )
        )
    }
    
    func testAmountCalculation() throws {
        let inputAmount = 10000
        let estimatedAmount = pool.estimatedAmount(forInputAmount: 1)
        print(estimatedAmount)
        
    }
}
