import Foundation
@testable import SolanaSwift

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
