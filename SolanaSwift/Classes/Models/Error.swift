//
//  Error.swift
//  p2p_wallet
//
//  Created by Chung Tran on 10/26/20.
//

import Foundation

public extension SolanaSDK {
    enum Error: LocalizedError {
        case accountNotFound
        case publicKeyNotFound
        case invalidURL
        case invalidStatusCode(code: Int)
        case responseError(ResponseError)
        case other(String)
        case socket(Swift.Error)
        case unknown
    }
}
