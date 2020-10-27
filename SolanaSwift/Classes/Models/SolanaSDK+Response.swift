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
        let id: String?
        let result: T
    }
    
    /// Get account info
    struct AccountInfo: Decodable {
        let context: Context
        public let value: AccountInfoValue?
    }
    
    struct AccountInfoValue: Decodable {
        let data: [String]
        let executable: Bool
        let lamports: UInt
        let owner: String
        let rentEpoch: String
    }
    
    /// Get balance
    struct Balance: Decodable {
        let context: Context
        public let value: Int
    }
    
    struct Context: Decodable {
        let slot: Int
    }
}
