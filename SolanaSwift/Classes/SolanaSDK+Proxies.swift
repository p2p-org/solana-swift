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
        sender: String,
        recipient: String,
        amount: SolanaSDK.Lamports,
        signature: String,
        blockhash: String,
        isSimulation: Bool
    ) -> Single<SolanaSDK.TransactionID>
    
    func transferSPLToken(
        sender: String,
        recipient: String,
        mintAddress: String,
        authority: String,
        amount: SolanaSDK.Lamports,
        decimals: SolanaSDK.Decimals,
        signature: String,
        blockhash: String
    ) -> Single<SolanaSDK.TransactionID>
}
