//
//  File.swift
//
//
//  Created by Giang Long Tran on 26.06.2023.
//

import Foundation
@testable import SolanaToken

class TestableSolanaTokenListStorage: SolanaTokenListStorage {
    var mockTokens: Set<TokenMetadata>?
    var getTokensCalled: Int = 0
    var saveTokensCalled: Int = 0

    func getTokens() async -> Set<TokenMetadata>? {
        getTokensCalled += 1
        return mockTokens
    }

    func save(tokens: Set<TokenMetadata>?) async {
        saveTokensCalled += 1
        mockTokens = tokens
    }
}
