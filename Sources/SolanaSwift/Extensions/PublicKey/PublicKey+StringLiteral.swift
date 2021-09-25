//
//  PublicKey+StringLiteral.swift
//  SolanaSwift
//
//  Created by Chung Tran on 16/08/2021.
//

import Foundation

extension SolanaSDK.PublicKey: ExpressibleByStringLiteral,
                    ExpressibleByUnicodeScalarLiteral,
                    ExpressibleByExtendedGraphemeClusterLiteral {
    public init(stringLiteral value: String) {
        self = try! .init(string: value)
    }
    
    public init(unicodeScalarLiteral value: String) {
        self = .init(stringLiteral: value)
    }
    
    public init(extendedGraphemeClusterLiteral value: String) {
        self = .init(stringLiteral: value)
    }
}

extension String {
    func toPublicKey() throws -> SolanaSDK.PublicKey {
        try SolanaSDK.PublicKey(string: self)
    }
}
