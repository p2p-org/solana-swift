//
//  SerumSwapError.swift
//  SolanaSwift
//
//  Created by Chung Tran on 10/08/2021.
//

import Foundation

struct SerumSwapError: Error, ExpressibleByStringLiteral {
    let description: StaticString
    init(stringLiteral value: StaticString) {
        self.description = value
    }
    
    static var unknown: Self {
        .init(stringLiteral: "Unknown")
    }
    
    static var unauthorized: Self {
        .init(stringLiteral: "Unauthorized")
    }
    
    init(_ string: StaticString) {
        self.init(stringLiteral: string)
    }
}
