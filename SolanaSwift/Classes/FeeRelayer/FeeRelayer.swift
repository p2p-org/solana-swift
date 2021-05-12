//
//  FeeRelayer.swift
//  SolanaSwift
//
//  Created by Chung Tran on 12/05/2021.
//

import Foundation
import RxSwift
import RxAlamofire

extension SolanaSDK {
    public struct FeeRelayer {
        // MARK: - Constants
        private static let feeRelayerUrl = "https://fee-relayer.solana.p2p.org"
        
        // MARK: - Methods
        public static func getFeePayerPubkey() -> Single<SolanaSDK.PublicKey>
        {
            RxAlamofire.request(.get, "\(feeRelayerUrl)/fee_payer/pubkey")
                .responseString()
                .map {try SolanaSDK.PublicKey(string: $0.1)}
                .take(1)
                .asSingle()
                .do(
                    onSuccess: {
                        Logger.log(message: $0.base58EncodedString, event: .response, apiMethod: "fee_payer/pubkey")
                    },
                    onError: {
                        Logger.log(message: $0.localizedDescription, event: .error, apiMethod: "fee_payer/pubkey")
                    })
        }
    }
}

