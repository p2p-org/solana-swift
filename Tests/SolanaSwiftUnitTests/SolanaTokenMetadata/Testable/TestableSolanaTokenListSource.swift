import Foundation
@testable import SolanaSwift

class TestableSolanaTokenListSource: SolanaTokenListSource {
    var downloadCalled: Int = 0
    var mockTokens: Set<TokenMetadata>?
    var shouldThrowError = false

    func download() async throws -> Set<TokenMetadata> {
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
