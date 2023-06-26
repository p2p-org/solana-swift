//
//  File 2.swift
//
//
//  Created by Giang Long Tran on 26.06.2023.
//

import Foundation
@testable import SolanaToken

class TestableSolanaTokenListSource: SolanaTokenListSource {
    var downloadCalled: Int = 0
    var mockTokens: Set<Token>?
    var shouldThrowError = false

    func download() async throws -> Set<Token> {
        downloadCalled += 1

        if shouldThrowError {
            throw Error.mockError
        }

        guard let tokens = mockTokens else {
            throw Error.tokensNotSet
        }

        return tokens
    }
}

extension TestableSolanaTokenListSource {
    enum Error: Swift.Error {
        case mockError
        case tokensNotSet
    }
}
