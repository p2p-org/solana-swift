//
//  SolanaSDK+SocketSubscriptions.swift
//  SolanaSwift
//
//  Created by Chung Tran on 03/12/2020.
//

import Foundation
import RxSwift

extension SolanaSDK {
    // MARK: - Account
    func accountSubscribe() -> Single<UInt64> {
        guard let account = accountStorage.account?.publicKey.base58EncodedString else
        {
            return .error(Error.publicKeyNotFound)
        }
        return request(parameters: [account, ["encoding": "jsonParsed"]])
    }
    
    func accountUnsubscribe() -> Single<Bool> {
        guard let account = accountStorage.account?.publicKey.base58EncodedString else
        {
            return .error(Error.publicKeyNotFound)
        }
        return request(parameters: [account])
    }
    
    // MARK: - Program account
    func programSubscribe(pubkey: String) -> Single<UInt64> {
        request(parameters: [pubkey, ["encoding": "jsonParsed"]])
    }
    
    func programUnsubscribe(pubkey: String) -> Single<Bool> {
        request(parameters: [pubkey])
    }
    
    // MARK: - Signature
    func signatureSubscribe(_ signature: String, commitment: Commitment = "max") -> Single<Int> {
        request(parameters: [signature, ["commitment": commitment]])
    }
    
    func signatureUnsubscribe(_ signature: String) -> Single<Bool> {
        request(parameters: [signature])
    }
}
