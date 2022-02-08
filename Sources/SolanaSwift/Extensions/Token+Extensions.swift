//
//  Token+Extensions.swift
//  SolanaSwift
//
//  Created by Chung Tran on 01/07/2021.
//

import Foundation

extension Array where Element == SolanaSDK.Token {
    public func excludingSpecialTokens() -> Self {
        var currentAddresses: Set<String> = []

        return filter { token in
            currentAddresses.insert(token.address).inserted &&
                !token.tags.contains(where: {$0.name == "nft"}) &&
                !token.tags.contains(where: {$0.name == "leveraged"}) &&
                !token.tags.contains(where: {$0.name == "bull"}) &&
                !token.tags.contains(where: {$0.name == "lp-token"})
        }
    }
}
