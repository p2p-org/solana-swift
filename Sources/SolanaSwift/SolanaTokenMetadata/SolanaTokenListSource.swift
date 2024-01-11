import Foundation

public protocol SolanaTokenListSource {
    func download() async throws -> Set<TokenMetadata>
}

public class SolanaTokenListSourceImpl: SolanaTokenListSource {
    // MARK: - Properties

    private let networkManager: NetworkManager
    private let tokenListURL: URL?

    public init(url: String, networkManager: NetworkManager) {
        tokenListURL = URL(string: url)
        self.networkManager = networkManager
    }

    public static func solanaLabs(networkManager: NetworkManager) -> SolanaTokenListSourceImpl {
        .init(
            url: "https://raw.githubusercontent.com/solana-labs/token-list/main/src/tokens/solana.tokenlist.json",
            networkManager: networkManager
        )
    }

    public static func p2p(networkManager: NetworkManager) -> SolanaTokenListSourceImpl {
        .init(
            url: "https://raw.githubusercontent.com/p2p-org/solana-token-list/main/src/tokens/solana.tokenlist.json",
            networkManager: networkManager
        )
    }

    // MARK: -

    public func download() async throws -> Set<TokenMetadata> {
        guard let url = tokenListURL else { throw APIClientError.invalidAPIURL }
        let urlRequest = URLRequest(url: url)

        // check for cancellation
        try Task.checkCancellation()

        // get data
        let data = try await networkManager.requestData(request: urlRequest)

        // check again for cancellation
        try Task.checkCancellation()

        // decode data
        let tokenList: TokensList = try JSONDecoder().decode(TokensList.self, from: data)

        // map tags
        let tokens: [TokenMetadata] = tokenList.tokens.map {
            var item = $0
            item.tags = (item._tags ?? []).map {
                tokenList.tags?[$0] ?? TokenTag(name: $0, description: $0)
            }
            return item
        }

        return Set(tokens)
    }
}

extension SolanaTokenListSourceImpl {
    struct TokensList: Codable {
        let name: String?
        let logoURI: String?
        let keywords: [String]?
        let tags: [String: TokenTag]?
        let timestamp: String
        var tokens: [TokenMetadata]
    }
}
