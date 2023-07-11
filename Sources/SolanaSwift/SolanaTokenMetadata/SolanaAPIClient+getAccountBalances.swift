public extension SolanaAPIClient {
    func getAccountBalances(
        for address: String,
        tokensRepository: TokenRepository,
        commitment: String = "confirmed"
    ) async throws -> (
        resolved: [AccountBalance],
        unresolved: [TokenAccount<SPLTokenAccountState>]
    ) {
        let tokenAccounts = try await getTokenAccountsByOwner(
            pubkey: address,
            params: .init(
                mint: nil,
                programId: TokenProgram.id.base58EncodedString
            ),
            configs: .init(
                commitment: commitment,
                encoding: "base64"
            )
        )

        var resolvedAccountBalances: [AccountBalance] = []
        var unresolvedAccountBalances: [TokenAccount<SPLTokenAccountState>] = []

        var unknownTokenAccountBalances: [TokenAccount<SPLTokenAccountState>] = []

        let tokenMetadatas = try await tokensRepository
            .get(addresses: tokenAccounts.map(\.account.data.mint.base58EncodedString))

        for tokenAccount in tokenAccounts {
            let token: TokenMetadata

            let tokenMintAddress: String = tokenAccount.account.data.mint.base58EncodedString
            if let resolvedToken = tokenMetadatas[tokenMintAddress] {
                token = resolvedToken
            } else {
                unknownTokenAccountBalances.append(tokenAccount)
                continue
            }

            let accountBalance = AccountBalance(
                pubkey: tokenAccount.pubkey,
                lamports: tokenAccount.account.data.lamports,
                token: token
            )

            resolvedAccountBalances.append(accountBalance)
        }

        // For case when token metadata in not in repository. We try to load on-chain
        let onChainTokenMetadataList = try await getMultipleMintDatas(
            mintAddresses: unknownTokenAccountBalances.map(
                \.account.data.mint.base58EncodedString
            ),
            commitment: commitment
        )

        for tokenAccount in unknownTokenAccountBalances {
            let tokenMetadata = onChainTokenMetadataList[tokenAccount.pubkey]

            if let tokenMetadata {
                // We have onchain token metadata
                let accountBalance = AccountBalance(
                    pubkey: tokenAccount.pubkey,
                    lamports: tokenAccount.account.data.lamports,
                    token: .unsupported(
                        mint: tokenAccount.account.data.mint.base58EncodedString,
                        decimals: tokenMetadata?.decimals ?? 1,
                        symbol: "",
                        supply: tokenMetadata?.supply
                    )
                )

                resolvedAccountBalances.append(accountBalance)
            } else {
                // We don't have onchain token metadata
                unresolvedAccountBalances.append(tokenAccount)
            }
        }

        return (resolvedAccountBalances, unresolvedAccountBalances)
    }
}
