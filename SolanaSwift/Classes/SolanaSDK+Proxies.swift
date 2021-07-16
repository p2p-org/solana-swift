//
//  SolanaSDK+Proxies.swift
//  SolanaSwift
//
//  Created by Chung Tran on 16/07/2021.
//

import Foundation
import RxSwift

/// Custom Proxy for handling the fee by another service
public protocol SolanaCustomFeeRelayerProxy {
    func getFeePayer() -> Single<String>
    
    func transferSOL(
        signature: String,
        recentBlockhash: String,
        to destination: String,
        amount: SolanaSDK.Lamports,
        isSimulation: Bool
    ) -> Single<SolanaSDK.TransactionID>
    
    func transferSPLToken(
        signature: String,
        recentBlockhash: String,
        mintAddress: String,
        from source: String,
        to destination: String,
        amount: SolanaSDK.Lamports,
        decimals: SolanaSDK.Decimals,
        isSimulation: Bool
    ) -> Single<SolanaSDK.TransactionID>
}
