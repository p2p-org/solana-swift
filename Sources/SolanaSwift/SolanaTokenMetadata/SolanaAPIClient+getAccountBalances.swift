public extension SolanaAPIClient {
    func getAccountBalances(
        for address: String,
        withToken2022: Bool,
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
            accountStateType: TokenAccountState.self,
            mintType: TokenMintState.self
        )

        // token 2022
        let token2022Accounts: (resolved: [AccountBalance], unresolved: [UnknownAccountBalance])
        if withToken2022 {
            async let tokens2022AccountsResult = getAccountBalances(
                for: address,
                tokensRepository: tokensRepository,
                commitment: commitment,
                programId: Token2022Program.id.base58EncodedString,
                accountStateType: Token2022AccountState.self,
                mintType: Token2022MintState.self
            )
            token2022Accounts = try await tokens2022AccountsResult
        } else {
            token2022Accounts = (resolved: [], unresolved: [])
        }

        // get result

        return try await(
            oldTokenAccountsResult.resolved + token2022Accounts.resolved,
            oldTokenAccountsResult.unresolved + token2022Accounts.unresolved
        )
    }

    // MARK: - Helpers

    private func getAccountBalances<
        T: TokenAccountLayoutState,
        M: MintLayoutState
    >(
        for address: String,
        tokensRepository: TokenRepository,
        commitment: String = "confirmed",
        programId: String,
        accountStateType _: T.Type,
        mintType _: M.Type
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

    private func convertResult<
        T: TokenAccountLayoutState,
        M: MintLayoutState
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
                tokenProgramId: tokenProgramId,
                minimumBalanceForRentExemption: tokenAccount.account.lamports
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
            let tokenMetadata = onChainTokenMetadataList[tokenAccount.account.data.mint.base58EncodedString]

            if let tokenMetadata {
                // We have onchain token metadata
                let accountBalance = AccountBalance(
                    pubkey: tokenAccount.pubkey,
                    lamports: tokenAccount.account.data.lamports,
                    token: .unsupported(
                        tags: nil,
                        mint: tokenAccount.account.data.mint.base58EncodedString,
                        decimals: tokenMetadata.decimals,
                        symbol: "",
                        supply: tokenMetadata.supply
                    ),
                    tokenProgramId: tokenProgramId,
                    minimumBalanceForRentExemption: tokenAccount.account.lamports
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
                        tokenProgramId: tokenProgramId,
                        minimumBalanceForRentExemption: tokenAccount.account.lamports
                    )
                )
            }
        }

        return (resolvedAccountBalances, unresolvedAccountBalances)
    }
}
