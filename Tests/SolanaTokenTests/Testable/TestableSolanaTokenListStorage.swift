//
//  File.swift
//
//
//  Created by Giang Long Tran on 26.06.2023.
//

import Foundation
@testable import SolanaToken

class TestableSolanaTokenListStorage: SolanaTokenListStorage {
    var mockTokens: Set<Token>?
    var getTokensCalled: Int = 0
    var saveTokensCalled: Int = 0

    func getTokens() async -> Set<Token>? {
        getTokensCalled += 1
        return mockTokens
    }

    func save(tokens: Set<Token>?) async {
        saveTokensCalled += 1
        mockTokens = tokens
    }
}
