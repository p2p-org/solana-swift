import Foundation

public enum TokensListParserError: Error {
    case invalidTokenlistURL
    case invalidTokenlistPath
}

public class TokensListParser {
    // MARK: -

    private let networkManager: NetworkManager
    private let tokenListURL: URL?

    public init(
        url: String = "https://raw.githubusercontent.com/p2p-org/solana-token-list/main/src/tokens/solana.tokenlist.json",
        networkManager: NetworkManager = URLSession.shared
    ) {
        self.tokenListURL = URL(string: url)
        self.networkManager = networkManager
    }

    // MARK: -

    public func parse(network: String) async throws -> Set<Token> {
        guard let url = tokenListURL else { throw TokensListParserError.invalidTokenlistURL }
        let urlRequest = URLRequest(url: url)

        // check for cancellation
        try Task.checkCancellation()

        // get data
        let data = try await networkManager.requestData(request: urlRequest)

        // check again for cancellation
        try Task.checkCancellation()

        // decode data
        let tokenList: TokensList
        do {
            tokenList = try JSONDecoder().decode(TokensList.self, from: data)
        } catch {
            // get json file
            let bundle = Bundle(for: TokensListParser.self)
            let path = bundle.path(forResource: network + ".tokens", ofType: "json")
            let jsonData =
                try Data(contentsOf: URL(fileURLWithPath: path ?! TokensListParserError.invalidTokenlistPath))
            tokenList = try JSONDecoder().decode(TokensList.self, from: jsonData)
        }

        // map tags
        var tokens: [Token] = tokenList.tokens.map {
            var item = $0
            item.tags = (item._tags ?? []).map {
                tokenList.tags[$0] ?? TokenTag(name: $0, description: $0)
            }
            return item
        }

        // TODO: Move outside parser
        // renBTC for devnet
        if network == "devnet" {
            tokens.append(
                .init(
                    _tags: nil,
                    chainId: 101,
                    address: "FsaLodPu4VmSwXGr3gWfwANe4vKf8XSZcCh1CEeJ3jpD",
                    symbol: "renBTC",
                    name: "renBTC",
                    decimals: 8,
                    logoURI: "https://raw.githubusercontent.com/p2p-org/solana-token-list/main/assets/mainnet/CDJWUqTcYTVAKXAVXoQZFes5JUFc7owSeq7eMQcDSbo5/logo.png",
                    extensions: .init(
                        website: "https://renproject.io/",
                        bridgeContract: nil,
                        assetContract: nil,
                        address: nil,
                        explorer: nil,
                        twitter: nil,
                        github: nil,
                        medium: nil,
                        tgann: nil,
                        tggroup: nil,
                        discord: nil,
                        serumV3Usdt: nil,
                        serumV3Usdc: "74Ciu5yRzhe8TFTHvQuEVbFZJrbnCMRoohBK33NNiPtv",
                        coingeckoId: "renbtc",
                        imageUrl: nil,
                        description: nil
                    )
                )
            )
        }
        return Set(tokens)
    }
}
