//
//  Error.swift
//  p2p_wallet
//
//  Created by Chung Tran on 10/26/20.
//

import Foundation

public extension SolanaSDK {
    enum Error: Swift.Error {
        case unauthorized
        case notFound
        
        // Invalid Requests
        case invalidRequest(reason: String)
        
        // Invalid responses
        case invalidResponse(ResponseError)
        
        // Socket error
        case socket(Swift.Error)
        
        // Other
        case other(String)
        case unknown
    }
}
