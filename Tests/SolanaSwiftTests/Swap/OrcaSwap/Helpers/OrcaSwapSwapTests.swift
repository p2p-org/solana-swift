//
//  OrcaSwapSwapTests.swift
//  
//
//  Created by Chung Tran on 19/10/2021.
//

import Foundation
import XCTest
import RxSwift
@testable import SolanaSwift

class OrcaSwapSwapTests: XCTestCase {
    // MARK: - Constants
    let btcMint = "9n4nbM75f5Ui33ZbPYXn59EwSgE8CGsHtAeTH5YFeJ9E"
    let ethMint = "2FPyTwcZLUg1MDrwsyoP4D6s1tM7hAkHYRjkNb5w6Pxk"
    let socnMint = "5oVNBeEEQvYi1cX3ir8Dx5n1P7pdxydbGF2X4TxVusJm"
    let solMint = "So11111111111111111111111111111111111111112"
    let ninjaMint = "FgX1WD9WzMU3yLwXaFSarPfkgzjLb2DZCqmkx9ExpuvJ"
    let usdcMint = "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v"
    let mngoMint = "MangoCzJ36AjZyKwVj3VnYU4GTonjfVEnJmvvWaxLac"
    let slimMint = "xxxxa1sKNGwFtw2kFn8XauW9xq8hBZ5kVtcSesTT9fW"
    let kuroMint = "2Kc38rfQ49DFaKHQaWbijkE7fcymUMLY5guUiUsDmFfn"
    
    // MARK: - Properties
    var solanaSDK: SolanaSDK!
    var orcaSwap: OrcaSwap!
    var endpoint: SolanaSDK.APIEndPoint! {
        .init(address: "https://p2p.rpcpool.com/", network: .mainnetBeta)
    }
    var phrase: String {
        "miracle pizza supply useful steak border same again youth silver access hundred"
    }
    
    var poolsRepository: [String: OrcaSwap.Pool]!
    
    // MARK: - Setup
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        let accountStorage = InMemoryAccountStorage()
        
        solanaSDK = SolanaSDK(
            endpoint: endpoint,
            accountStorage: accountStorage
        )
        
        let account = try SolanaSDK.Account(
            phrase: phrase.components(separatedBy: " "),
            network: endpoint.network
        )
        try accountStorage.save(account)
        
        orcaSwap = OrcaSwap(
            apiClient: OrcaSwap.MockAPIClient(network: "mainnet"),
            solanaClient: solanaSDK,
            accountProvider: solanaSDK,
            notificationHandler: solanaSDK
        )
        
        _ = orcaSwap.load().toBlocking().materialize()
        
        poolsRepository = try JSONDecoder().decode([String: OrcaSwap.Pool].self, from: OrcaSwap.getFileFrom(type: "pools", network: "mainnet"))
    }
    
    // MARK: - Helper
    struct RawPool {
        init(name: String, reversed: Bool = false) {
            self.name = name
            self.reversed = reversed
        }
        
        let name: String
        let reversed: Bool
    }
    
    func fillPoolsBalancesAndSwap(
        fromWalletPubkey: String,
        toWalletPubkey: String?,
        bestPoolsPair: [RawPool],
        amount: Double,
        slippage: Double,
        isSimulation: Bool
    ) throws -> Single<OrcaSwap.SwapResponse> {
        let bestPoolsPair = try Single.zip(
            bestPoolsPair.map { rawPool -> Single<OrcaSwap.Pool> in
                var pool = poolsRepository[rawPool.name]!
                if rawPool.reversed {
                    pool = pool.reversed
                }
                return pool.filledWithUpdatedBalances(solanaClient: solanaSDK)
            }
        ).toBlocking().first()!
        
        let swapSimulation = orcaSwap.swap(
            fromWalletPubkey: fromWalletPubkey,
            toWalletPubkey: toWalletPubkey,
            bestPoolsPair: bestPoolsPair,
            amount: amount,
            slippage: 0.5,
            isSimulation: isSimulation
        )
        
        return swapSimulation
    }
}
