//
//  File.swift
//  
//
//  Created by Chung Tran on 13/10/2021.
//

import Foundation
import RxSwift

public extension OrcaSwap {
    struct Pool: Decodable {
        let account: String
        let authority: String
        let nonce: UInt64
        let poolTokenMint: String
        var tokenAccountA: String
        var tokenAccountB: String
        let feeAccount: String
        let hostFeeAccount: String?
        let feeNumerator: UInt64
        let feeDenominator: UInt64
        let ownerTradeFeeNumerator: UInt64
        let ownerTradeFeeDenominator: UInt64
        let ownerWithdrawFeeNumerator: UInt64
        let ownerWithdrawFeeDenominator: UInt64
        let hostFeeNumerator: UInt64
        let hostFeeDenominator: UInt64
        var tokenAName: String
        var tokenBName: String
        let curveType: String
        let amp: UInt64?
        let programVersion: UInt64?
        let deprecated: Bool?
        
        // balance (lazy load)
        var tokenABalance: SolanaSDK.TokenAccountBalance?
        var tokenBBalance: SolanaSDK.TokenAccountBalance?
        
        var reversed: Pool {
            var reversedPool = self
            swap(&reversedPool.tokenAccountA, &reversedPool.tokenAccountB)
            swap(&reversedPool.tokenAName, &reversedPool.tokenBName)
            swap(&reversedPool.tokenABalance, &reversedPool.tokenBBalance)
            return reversedPool
        }
        
//        func getTokenAmountsFromInput(
//            inputTokenName: String
//        ) -> (UInt64, UInt64) {
//            inputTokenName == tokenAName ? (tokenA)
//        }
//        
//        func getOutputAmount(
//            fromInputAmount inputAmount: UInt64,
//            inputTokenName: String
//        ) -> UInt64 {
//            switch curveType {
//            case "Stable":
//                
//            case "ConstantProduct":
//                
//            default:
//                return 0
//            }
//        }
    }
    
    typealias Pools = [String: Pool] // [poolId: string]: PoolConfig;
}

private var balancesCache = [String: SolanaSDK.TokenAccountBalance]()

extension OrcaSwap.Pools {
    func fixedPool(
        forRoute route: String,
        inputTokenName: String,
        solanaClient: OrcaSwapSolanaClient
    ) -> Single<OrcaSwap.Pool>? {
        guard var pool = self[route] else {return nil}
        
        // get balances
        let getBalancesRequest: Single<(SolanaSDK.TokenAccountBalance, SolanaSDK.TokenAccountBalance)>
        if let tokenABalance = pool.tokenABalance ?? balancesCache[pool.tokenAccountA],
           let tokenBBalance = pool.tokenBBalance ?? balancesCache[pool.tokenAccountB]
        {
            getBalancesRequest = .just((tokenABalance, tokenBBalance))
        } else {
            getBalancesRequest = Single.zip(
                solanaClient.getTokenAccountBalance(pubkey: pool.tokenAccountA, commitment: nil),
                solanaClient.getTokenAccountBalance(pubkey: pool.tokenAccountB, commitment: nil)
            )
        }
        
        return getBalancesRequest
            .map {tokenABalane, tokenBBalance in
                pool.tokenABalance = tokenABalane
                pool.tokenBBalance = tokenBBalance
                
                let pair = route.components(separatedBy: "/")
                if pair[safe: 1] == inputTokenName {
                    pool = pool.reversed
                }
                
                return pool
            }
    }
}
