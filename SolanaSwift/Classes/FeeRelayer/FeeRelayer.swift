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
                .validate(statusCode: 200..<300)
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
        
        private static func sendTransaction(
            path: String,
            params: SolanaFeeRelayerTransferParams
        ) -> Single<SolanaSDK.TransactionID> {
            do {
                var urlRequest = try URLRequest(
                    url: "\(feeRelayerUrl)\(path)",
                    method: .post,
                    headers: [.contentType("application/json")]
                )
                urlRequest.httpBody = try JSONEncoder().encode(EncodableWrapper(wrapped: params))
                
                return RxAlamofire.request(urlRequest)
                    .validate(statusCode: 200..<300)
                    .responseString()
                    .map {$0.1}
                    .take(1)
                    .asSingle()
            } catch {
                return .error(error)
            }
        }
        
        // MARK: - Helpers
        
    }
}

