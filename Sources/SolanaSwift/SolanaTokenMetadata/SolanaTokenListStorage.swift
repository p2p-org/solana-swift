import Foundation

public protocol SolanaTokenListStorage {
    func getTokens() async -> Set<TokenMetadata>?
    func save(tokens: Set<TokenMetadata>?) async
}

public class InMemorySolanaTokenListStorage: SolanaTokenListStorage {
    var value: Set<TokenMetadata>? = []

    public init() {}

    public func getTokens() async -> Set<TokenMetadata>? {
        value
    }

    public func save(tokens: Set<TokenMetadata>?) async {
        value = tokens
    }
}
