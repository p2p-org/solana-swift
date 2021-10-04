//
//  SerumSwapError.swift
//  SolanaSwift
//
//  Created by Chung Tran on 10/08/2021.
//

import Foundation

struct SerumSwapError: Error, Equatable, ExpressibleByStringLiteral {
    let description: String
    var minOrderSize: Double? // Amount is too small
    
    init(stringLiteral value: String) {
        self.description = value
    }
    
    static var unknown: Self {
        .init(stringLiteral: "Unknown")
    }
    
    static var unauthorized: Self {
        .init(stringLiteral: "Unauthorized")
    }
    
    static var invalidMarket: Self {
        .init(stringLiteral: "Invalid market")
    }
    
    static var noMarketFound: Self {
        .init(stringLiteral: "No market found")
    }
    
    static var couldNotRetrieveExchangeRate: Self {
        .init(stringLiteral: "Could not retrieve exchange rate")
    }
    
    static var somePublicKeysArentValid: Self {
        .init(stringLiteral: "Some public keys aren't valid")
    }
    
    static var marketIsNotAvailable: Self {
        .init(stringLiteral: "Market is not available")
    }
    
    static func amountIsTooSmall(minOrderSize: Double?) -> SerumSwapError {
        var err = SerumSwapError("Amount is too small")
        err.minOrderSize = minOrderSize
        return err
    }
    
    static var couldNotCalculateMinOrderSize: Self {
        .init(stringLiteral: "Could not calculate minimum order size")
    }
    
    init(_ string: String) {
        self.init(stringLiteral: string)
    }
}

extension Error {
    func isEqualTo(_ serumSwapError: SerumSwapError) -> Bool {
        (self as? SerumSwapError) == serumSwapError
    }
}
