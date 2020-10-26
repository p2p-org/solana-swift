//
//  Response.swift
//  p2p_wallet
//
//  Created by Chung Tran on 10/26/20.
//

import Foundation

public extension SolanaSDK {
    internal struct Response<T: Decodable>: Decodable {
        let jsonrpc: String
        let id: Int
        let result: T
    }
    
    /// Get balance
    struct Balance: Decodable {
        let context: BalanceContext
        let value: Int
    }
    
    struct BalanceContext: Decodable {
        let slot: Int
    }
}
