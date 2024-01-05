public extension SolanaAPIClient {
    func getAccountBalances<
        T: SolanaSPLTokenAccountState,
        M: SolanaSPLTokenMintState
    >(
        for address: String,
        tokensRepository: TokenRepository,
        commitment: String = "confirmed",
        programId: String = TokenProgram.id.base58EncodedString,
        accountStateType _: T.Type = SPLTokenAccountState.self,
        mintType _: M.Type = SPLTokenMintState.self
    ) async throws -> (
        resolved: [AccountBalance],
        unresolved: [UnknownAccountBalance]
    ) {
        let tokenAccounts = try await getTokenAccountsByOwner(
            pubkey: address,
            params: .init(
                mint: nil,
                programId: programId
            ),
            configs: .init(
                commitment: commitment,
                encoding: "base64"
            ),
            decodingTo: T.self
        )

        return try await convertResult(
            tokenAccounts: tokenAccounts,
            tokensRepository: tokensRepository,
            tokenProgramId: programId,
            mintType: M.self
        )
    }

    func getAccountBalancesWithToken2022(
        for address: String,
        tokensRepository: TokenRepository,
        commitment: String = "confirmed"
    ) async throws -> (
        resolved: [AccountBalance],
        unresolved: [UnknownAccountBalance]
    ) {
        // old token standard
        async let oldTokenAccountsResult = getAccountBalances(
            for: address,
            tokensRepository: tokensRepository,
            commitment: commitment,
            programId: TokenProgram.id.base58EncodedString,
            accountStateType: SPLTokenAccountState.self,
            mintType: SPLTokenMintState.self
        )

        // token 2022
        async let tokens2022AccountsResult = getAccountBalances(
            for: address,
            tokensRepository: tokensRepository,
            commitment: commitment,
            programId: Token2022Program.id.base58EncodedString,
            accountStateType: Token2022AccountState.self,
            mintType: Token2022MintState.self
        )

        // get result

        return try await(
            oldTokenAccountsResult.resolved + tokens2022AccountsResult.resolved,
            oldTokenAccountsResult.unresolved + tokens2022AccountsResult.unresolved
        )
    }

    // MARK: - Helpers

    private func convertResult<
        T: SolanaSPLTokenAccountState,
        M: SolanaSPLTokenMintState
    >(
        tokenAccounts: [TokenAccount<T>],
        tokensRepository: TokenRepository,
        commitment: String = "confirmed",
        tokenProgramId: String,
        mintType _: M.Type
    ) async throws -> (
        resolved: [AccountBalance],
        unresolved: [UnknownAccountBalance]
    ) {
        var resolvedAccountBalances: [AccountBalance] = []
        var unresolvedAccountBalances: [UnknownAccountBalance] = []

        var unknownTokenAccountBalances: [TokenAccount<T>] = []

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
                token: token,
                tokenProgramId: tokenProgramId
            )

            resolvedAccountBalances.append(accountBalance)
        }

        // For case when token metadata in not in repository. We try to load on-chain
        let onChainTokenMetadataList = try await getMultipleMintDatas(
            mintAddresses: unknownTokenAccountBalances.map(
                \.account.data.mint.base58EncodedString
            ),
            commitment: commitment,
            mintType: M.self
        )

        for tokenAccount in unknownTokenAccountBalances {
            let tokenMetadata = onChainTokenMetadataList[tokenAccount.pubkey]

            if let tokenMetadata {
                // We have onchain token metadata
                let accountBalance = AccountBalance(
                    pubkey: tokenAccount.pubkey,
                    lamports: tokenAccount.account.data.lamports,
                    token: .unsupported(
                        tags: nil,
                        mint: tokenAccount.account.data.mint.base58EncodedString,
                        decimals: tokenMetadata?.decimals ?? 0,
                        symbol: "",
                        supply: tokenMetadata?.supply
                    ),
                    tokenProgramId: tokenProgramId
                )

                resolvedAccountBalances.append(accountBalance)
            } else {
                // We don't have onchain token metadata
                unresolvedAccountBalances.append(
                    .init(
                        pubkey: tokenAccount.pubkey,
                        lamports: tokenAccount.account.data.lamports,
                        mintAddress: tokenAccount.account.data.mint.base58EncodedString,
                        decimals: 0,
                        supply: nil,
                        tokenProgramId: tokenProgramId
                    )
                )
            }
        }

        return (resolvedAccountBalances, unresolvedAccountBalances)
    }
}
