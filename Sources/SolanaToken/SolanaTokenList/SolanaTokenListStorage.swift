import Foundation

public protocol SolanaTokenListStorage {
    func getTokens() async -> Set<Token>?
    func save(tokens: Set<Token>?) async
}

public class InMemorySolanaTokenListStorage: SolanaTokenListStorage {
    var value: Set<Token>? = []

    public init() {}

    public func getTokens() async -> Set<Token>? {
        value
    }

    public func save(tokens: Set<Token>?) async {
        value = tokens
    }
}
