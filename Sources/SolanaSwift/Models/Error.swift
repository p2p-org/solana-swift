//
//  Error.swift
//  p2p_wallet
//
//  Created by Chung Tran on 10/26/20.
//

import Foundation

public extension SolanaSDK {
    enum Error: Swift.Error, Equatable {
        public static func == (lhs: SolanaSDK.Error, rhs: SolanaSDK.Error) -> Bool {
            switch (lhs, rhs) {
            case (.unauthorized, .unauthorized):
                return true
            case (.notFound, .notFound):
                return true
            case (.invalidRequest(let rs1), .invalidRequest(let rs2)):
                return rs1 == rs2
            case (.invalidResponse(let rs1), .invalidResponse(let rs2)):
                return rs1.code == rs2.code
            case (.socket(let er1), .socket(let er2)):
                return er1.localizedDescription == er2.localizedDescription
            case (.other(let rs1), .other(let rs2)):
                return rs1 == rs2
            case (.unknown, .unknown):
                return true
            case (.transactionError(let err1, let logs1), .transactionError(let err2, let logs2)):
                return err1.jsonString == err2.jsonString && logs1 == logs2
            default:
                return false
            }
        }
        
        case unauthorized
        case notFound
        case assertionFailed
        
        // Invalid Requests
        case invalidRequest(reason: String? = nil)
        
        // Invalid responses
        case invalidResponse(ResponseError)
        
        // Transaction error
        case transactionError(TransactionError, logs: [String])
        
        // Socket error
        case socket(Swift.Error)
        
        // Other
        case other(String)
        case unknown
        
        // Predefined error
        static var couldNotRetrieveAccountInfo: Self {
            .other("Could not retrieve account info")
        }
    }
}
