//
//  Error.swift
//  p2p_wallet
//
//  Created by Chung Tran on 10/26/20.
//

import Foundation

public extension SolanaSDK {
    public enum Error: Swift.Error {
        case accountNotFound
        case publicKeyNotFound
        case invalidURL
        case invalidStatusCode(code: Int)
    }
}
