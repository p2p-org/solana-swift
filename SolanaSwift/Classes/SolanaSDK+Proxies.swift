//
//  SolanaSDK+Proxies.swift
//  SolanaSwift
//
//  Created by Chung Tran on 16/07/2021.
//

import Foundation
import RxSwift

public protocol SolanaCustomClientProxy {
    func transferSOL(
        to destination: String,
        amount: SolanaSDK.Lamports,
        isSimulation: Bool
    ) -> Single<SolanaSDK.TransactionID>
    
    func transferSPLToken(
        mintAddress: String,
        from source: String,
        to destination: String,
        amount: SolanaSDK.Lamports,
        decimals: SolanaSDK.Decimals,
        isSimulation: Bool
    ) -> Single<SolanaSDK.TransactionID>
}
