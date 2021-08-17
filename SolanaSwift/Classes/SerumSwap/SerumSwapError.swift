//
//  SerumSwapError.swift
//  SolanaSwift
//
//  Created by Chung Tran on 10/08/2021.
//

import Foundation

struct SerumSwapError: Error, Equatable, ExpressibleByStringLiteral {
    let description: String
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
    
    init(_ string: String) {
        self.init(stringLiteral: string)
    }
}

extension Error {
    func isEqualTo(_ serumSwapError: SerumSwapError) -> Bool {
        (self as? SerumSwapError) == serumSwapError
    }
}
