import Foundation

public class TokensRepository: SolanaTokensRepository {
    // MARK: - Properties

    private static var tokenCache = Cache<String, Set<Token>>()
    private let tokenCacheKey = "TokenRepositoryTokensKey"

    private let tokenListParser: TokensListParser
    private let endpoint: APIEndPoint

    public init(endpoint: APIEndPoint, tokenListParser: TokensListParser = .init()) {
        self.endpoint = endpoint
        self.tokenListParser = tokenListParser
    }

    // MARK: - Public Methods

    /// Returns all tokens
    /// - Parameters:
    ///  - useCache: wether to use cached value or not, default - true
    /// - Throws: TokenRepositoryError
    /// - Returns Set of tokens
    ///
    public func getTokensList(useCache: Bool = true) async throws -> Set<Token> {
        if useCache, let tokens = await TokensRepository.tokenCache.value(forKey: tokenCacheKey) {
            return tokens
        }
        let tokenlist = try await tokenListParser.parse(network: endpoint.network.rawValue)
        await TokensRepository.tokenCache.insert(tokenlist, forKey: tokenCacheKey)
        return tokenlist
    }
}
