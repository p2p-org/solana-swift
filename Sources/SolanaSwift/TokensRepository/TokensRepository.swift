import Foundation

public class TokensRepository {

    // MARK: -
    
    public init(apiClient: SolanaAPIClient, tokenListParser: TokensListParser = .init()) {
        self.apiClient = apiClient
        self.tokenListParser = tokenListParser
    }

    private let tokenListParser: TokensListParser
    private let apiClient: SolanaAPIClient
    private static var tokenCache = Cache<String, Set<Token>>()
    private let tokenCacheKey = "TokenRepositoryTokensKey"
    private var endpoint: APIEndPoint {
        apiClient.endpoint
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
    
    /// Method retrieves token wallets
    /// - Parameters:
    ///  - account: Public key of an account
    /// - Throws: TokenRepositoryError
    /// - Returns array of Wallet
    ///
    public func getTokenWallets(account: String) async throws -> [Wallet] {
        async let accounts = try await apiClient.getTokenAccountsByOwner(pubkey: account,
                                                                         params: .init(mint: nil, programId: TokenProgram.id.base58EncodedString),
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
        guard mintDatas.count == unknownAccounts.count else { throw SolanaError.unknown }
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
        do {
            _ = try await apiClient.getAccountInfo(account: account) as BufferInfo<EmptyInfo>?
        } catch let error as SolanaError where error == .couldNotRetrieveAccountInfo {
            return false
        } catch let error {
            throw error
        }
        return true
    }

    // MARK: -
}
