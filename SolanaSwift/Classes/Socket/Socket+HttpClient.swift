//
//  Socket+HttpClient.swift
//  SolanaSwift
//
//  Created by Chung Tran on 03/12/2020.
//

import Foundation
import RxSwift

public protocol SolanaSoketHttpClient: class {
    func accountSubscribe() -> Single<UInt64>
    func accountUnsubscribe() -> Single<Bool>
    func programSubscribe(pubkey: String) -> Single<UInt64>
    func programUnsubscribe(pubkey: String) -> Single<Bool>
    func signatureSubscribe(_ signature: String, commitment: String) -> Single<Int>
    func signatureUnsubscribe(_ signature: String) -> Single<Bool>
}

extension SolanaSDK: SolanaSoketHttpClient {}
