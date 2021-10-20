//
//  File.swift
//  
//
//  Created by Chung Tran on 20/10/2021.
//

import Foundation
import RxSwift
@testable import SolanaSwift

extension OrcaSwap.Pool {
    func filledWithUpdatedBalances(solanaClient: OrcaSwapSolanaClient) -> Single<OrcaSwap.Pool> {
        Single.zip(
            solanaClient.getTokenAccountBalance(pubkey: tokenAccountA, commitment: nil),
            solanaClient.getTokenAccountBalance(pubkey: tokenAccountB, commitment: nil)
        )
        .map { tokenABalance, tokenBBalance in
            var pool = self
            pool.tokenABalance = tokenABalance
            pool.tokenBBalance = tokenBBalance
            return pool
        }
    }
}
