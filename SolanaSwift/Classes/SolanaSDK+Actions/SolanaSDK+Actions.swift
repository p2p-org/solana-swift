//
//  SolanaSDK+Extensions.swift
//  SolanaSwift
//
//  Created by Chung Tran on 11/9/20.
//

import Foundation
import RxSwift

extension SolanaSDK {
    func serializeTransaction(
        _ transaction: Transaction,
        recentBlockhash: String? = nil,
        signers: [Account]
    ) -> Single<String> {
        // get recentBlockhash
        let getRecentBlockhashRequest: Single<String>
        if let recentBlockhash = recentBlockhash {
            getRecentBlockhashRequest = .just(recentBlockhash)
        } else {
            getRecentBlockhashRequest = getRecentBlockhash()
        }
        
        // serialize transaction
        return getRecentBlockhashRequest
            .map {recentBlockhash -> String in
                var transaction = transaction
                transaction.message.recentBlockhash = recentBlockhash
                try transaction.sign(signers: signers)
                guard let serializedTransaction = try transaction.serialize().toBase64() else {
                    throw Error.other("Could not serialize transaction")
                }
                return serializedTransaction
            }
    }
}
