import Foundation

public protocol SolanaTokensRepositoryCache {
    func getTokens() async -> Set<Token>?
    func save(tokens: Set<Token>) async
}

public class InMemoryTokensRepositoryCache: SolanaTokensRepositoryCache {
    var tokenCache = Cache<String, Set<Token>>()
    private let tokenCacheKey = "TokenRepositoryTokensKey"
    
    public init() {}
    
    public func getTokens() async -> Set<Token>? {
        await tokenCache.value(forKey: tokenCacheKey)
    }
    
    public func save(tokens: Set<Token>) async {
        await tokenCache.insert(tokens, forKey: tokenCacheKey)
    }
}
