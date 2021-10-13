//
//  File.swift
//  
//
//  Created by Chung Tran on 13/10/2021.
//

import Foundation
import RxSwift

public protocol OrcaSwapSolanaClient {
    func getTokenAccountBalance(pubkey: String, commitment: SolanaSDK.Commitment?) -> Single<SolanaSDK.TokenAccountBalance>
}
