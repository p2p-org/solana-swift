import Foundation

public actor TokenRepository {

    // MARK: -
    
    public init(endpoint: APIEndPoint, tokenListParser: TokensListParser) {
        self.endpoint = endpoint
        self.tokenListParser = tokenListParser
    }

    private let tokenListParser: TokensListParser
    private let endpoint: APIEndPoint
    private static var tokenCache = Cache<String, Set<Token>>()
    private let tokenCacheKey = "TokenRepositoryTokensKey"
    
    // MARK: - Public Methods
    
    /// Returns all tokens
    /// - Parameters:
    ///  - useCache: wether to use cached value or not, default - true
    /// - Throws: TokenRepositoryError
    /// - Returns Set of tokens
    ///
    public func getTokensList(useCache: Bool = true) async throws -> Set<Token> {
        if useCache, let tokens = TokenRepository.tokenCache.value(forKey: tokenCacheKey) {
            return tokens
        }
        let tokenlist = try await tokenListParser.parse(network: endpoint.network.rawValue)
        TokenRepository.tokenCache.insert(tokenlist, forKey: tokenCacheKey)
        return tokenlist
    }
    
    /// Method retrieves token wallets
    /// - Parameters:
    ///  - account: Public key of an account
    /// - Throws: TokenRepositoryError
    /// - Returns array of Wallet
    ///
    public func getTokenWallets(account: String) async throws -> [Wallet] {
        let apiClient = JSONRPCAPIClient(endpoint: endpoint)
        async let accounts = try await apiClient.getTokenAccountsByOwner(pubkey: account,
                                                               params: .init(mint: nil, programId: PublicKey.tokenProgramId.base58EncodedString),
                                                               configs: .init(encoding: "base64"))
        async let tokens = try await getTokensList()
        var knownWallets = [Wallet]()
        var unknownAccounts = [(String, AccountInfo)]()
        
        let (list, supportedTokens) = (try await accounts, try await tokens)

        for item in list {
            let pubkey = item.pubkey
            let accountInfo = item.account.data

            let mintAddress = accountInfo.mint.base58EncodedString
            // known token
            if let token = supportedTokens.first(where: {$0.address == mintAddress}) {
                knownWallets.append(
                    Wallet(
                        pubkey: pubkey,
                        lamports: accountInfo.lamports,
                        token: token
                    )
                )
            } else {
                // unknown token
                unknownAccounts.append((item.pubkey, item.account.data))
            }
        }
        let mintDatas = try await apiClient.getMultipleMintDatas(mintAddresses: unknownAccounts.map{ $0.1.mint.base58EncodedString })
        guard mintDatas.count == unknownAccounts.count else { throw SolanaSDK.Error.unknown }
        let wallets = mintDatas.enumerated().map {
            Wallet(
                pubkey: unknownAccounts[$0].0,
                lamports: unknownAccounts[$0].1.lamports,
                token: .unsupported(
                    mint: unknownAccounts[$0].1.mint.base58EncodedString,
                    decimals: $1.value.decimals
                )
            )
        }
        return knownWallets + wallets
    }
    
    /// Method checks account validation
    /// - Parameters:
    ///  - account: Public key of an account
    /// - Throws: TokenRepositoryError
    /// - Returns wether account is valid
    ///
    public func checkAccountValidation(account: String) async throws -> Bool {
        let apiClient = JSONRPCAPIClient(endpoint: endpoint)
        do {
            _ = try await apiClient.getAccountInfo(account: account) as BufferInfo<EmptyInfo>?
        } catch let error as SolanaSDK.Error where error == .couldNotRetrieveAccountInfo {
            return false
        } catch let error {
            throw error
        }
        return true
    }

    // MARK: -
}

public enum TokensListParserError: Error {
    case invalidTokenlistURL
    case invalidTokenlistPath
}

public class TokensListParser {
    
    // MARK: -
    
    private let networkManager: NetworkManager
    private let tokenListURL = URL(string: "https://raw.githubusercontent.com/solana-labs/token-list/main/src/tokens/solana.tokenlist.json")
    
    public init(networkManager: NetworkManager = URLSession.shared) {
        self.networkManager = networkManager
    }
    
    // MARK: -
    
    public func parse(network: String) async throws -> Set<Token> {
        guard let url = tokenListURL else { throw TokensListParserError.invalidTokenlistURL }
        let urlRequest = URLRequest(url: url)
        let data = try await networkManager.requestData(request: urlRequest)
        let tokenList: TokensList
        do {
            tokenList = try JSONDecoder().decode(TokensList.self, from: data)
        } catch {
            // get json file
            let bundle = Bundle(for: TokensListParser.self)
            let path = bundle.path(forResource: network + ".tokens", ofType: "json")
            let jsonData = try Data(contentsOf: URL(fileURLWithPath: path ?! TokensListParserError.invalidTokenlistPath))
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
                    logoURI: "https://raw.githubusercontent.com/solana-labs/token-list/main/assets/mainnet/CDJWUqTcYTVAKXAVXoQZFes5JUFc7owSeq7eMQcDSbo5/logo.png",
                    extensions: .init(website: "https://renproject.io/", bridgeContract: nil, assetContract: nil, address: nil, explorer: nil, twitter: nil, github: nil, medium: nil, tgann: nil, tggroup: nil, discord: nil, serumV3Usdt: nil, serumV3Usdc: "74Ciu5yRzhe8TFTHvQuEVbFZJrbnCMRoohBK33NNiPtv", coingeckoId: "renbtc", imageUrl: nil, description: nil)
                )
            )
        }
        return Set(tokens)
    }
}
