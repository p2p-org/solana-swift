//
//  Token+Extensions.swift
//  SolanaSwift
//
//  Created by Chung Tran on 01/07/2021.
//

import Foundation

extension Array where Element == SolanaSDK.Token {
    public func excludingSpecialTokens() -> Self {
        reduce(Self()) { (result, token) -> Self in
            var result = result
            if !result.contains(where: {$0.address == token.address}) &&
                !token.tags.contains(where: {$0.name == "nft"}) &&
                !token.tags.contains(where: {$0.name == "leveraged"}) &&
                !token.tags.contains(where: {$0.name == "bull"}) &&
                !token.tags.contains(where: {$0.name == "lp-token"})
            {
                result.append(token)
            }
            return result
        }
    }
}
