import Foundation

public class TokensRepository: SolanaTokensRepository {
    // MARK: - Properties

    private let cache: SolanaTokensRepositoryCache

    private let tokenListParser: TokensListParser
    private let endpoint: APIEndPoint

    public init(
        endpoint: APIEndPoint,
        tokenListParser: TokensListParser = .init(),
        cache: SolanaTokensRepositoryCache = InMemoryTokensRepositoryCache()
    ) {
        self.endpoint = endpoint
        self.tokenListParser = tokenListParser
        self.cache = cache
    }

    // MARK: - Public Methods

    /// Returns all tokens
    /// - Parameters:
    ///  - useCache: wether to use cached value or not, default - true
    /// - Throws: TokenRepositoryError
    /// - Returns Set of tokens
    ///
    public func getTokensList(useCache: Bool = true) async throws -> Set<Token> {
        if useCache, let tokens = await cache.getTokens() {
            return tokens
        }
        let tokenlist = try await tokenListParser.parse(network: endpoint.network.rawValue)
        await cache.save(tokens: tokenlist)
        return tokenlist
    }
}
