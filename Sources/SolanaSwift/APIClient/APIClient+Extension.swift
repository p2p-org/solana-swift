import Foundation

// MARK: - TokenRepository

public extension SolanaAPIClient {
    // MARK: - Convenience methods

    func getMinimumBalanceForRentExemption(span: UInt64) async throws -> UInt64 {
        try await getMinimumBalanceForRentExemption(dataLength: span, commitment: "recent")
    }

    func getRecentBlockhash() async throws -> String {
        try await getRecentBlockhash(commitment: nil)
    }

    func observeSignatureStatus(signature: String) -> AsyncStream<TransactionStatus> {
        observeSignatureStatus(signature: signature, timeout: 60, delay: 2)
    }

    // MARK: - Additional methods

    func getMultipleMintDatas(mintAddresses: [String],
                              programId: String = TokenProgram.id.base58EncodedString) async throws -> [String: Mint]
    {
        let accounts: [BufferInfo<Mint>] = try await getMultipleAccounts(pubkeys: mintAddresses)
        var mintDict = [String: Mint]()
        if accounts.contains(where: { $0.owner != programId }) == true {
            throw SolanaError.other("Invalid mint owner")
        }
        let result = accounts.map(\.data)
        guard result.count == mintAddresses.count else {
            throw SolanaError.other("Some of mint data are missing")
        }

        for (index, address) in mintAddresses.enumerated() {
            mintDict[address] = result[index]
        }
        return mintDict
    }

    func checkIfAssociatedTokenAccountExists(
        owner: PublicKey,
        mint: String
    ) async throws -> Bool {
        let mintAddress = try mint.toPublicKey()

        let associatedTokenAccount = try PublicKey.associatedTokenAddress(
            walletAddress: owner,
            tokenMintAddress: mintAddress
        )

        let bufferInfo: BufferInfo<AccountInfo>? = try await getAccountInfo(account: associatedTokenAccount.base58EncodedString)
        return bufferInfo?.data.mint == mintAddress
    }

    /// Method checks account validation
    /// - Parameters:
    ///  - account: Public key of an account
    /// - Throws: TokenRepositoryError
    /// - Returns wether account is valid
    ///
    func checkAccountValidation(account: String) async throws -> Bool {
        (try await getAccountInfo(account: account) as BufferInfo<EmptyInfo>?) != nil
    }

    func findSPLTokenDestinationAddress(
        mintAddress: String,
        destinationAddress: String
    ) async throws -> SPLTokenDestinationAddress {
        var address: String
        var accountInfo: BufferInfo<AccountInfo>?
        do {
            accountInfo = try await getAccountInfoThrowable(account: destinationAddress)
            let toTokenMint = accountInfo?.data.mint.base58EncodedString
            // detect if destination address is already a SPLToken address
            if mintAddress == toTokenMint {
                address = destinationAddress
                // detect if destination address is a SOL address
            } else if accountInfo?.owner == SystemProgram.id.base58EncodedString {
                let owner = try PublicKey(string: destinationAddress)
                let tokenMint = try PublicKey(string: mintAddress)
                // create associated token address
                address = try PublicKey.associatedTokenAddress(
                    walletAddress: owner,
                    tokenMintAddress: tokenMint
                ).base58EncodedString
            } else {
                throw SolanaError.invalidRequest(reason: "Wallet address is not valid")
            }
        } catch let error as SolanaError where error == .couldNotRetrieveAccountInfo {
            let owner = try PublicKey(string: destinationAddress)
            let tokenMint = try PublicKey(string: mintAddress)
            // create associated token address
            address = try PublicKey.associatedTokenAddress(
                walletAddress: owner,
                tokenMintAddress: tokenMint
            ).base58EncodedString
        } catch {
            throw error
        }

        // address needs here
        let toPublicKey = try PublicKey(string: address)
        // if destination address is an SOL account address
        var isUnregisteredAsocciatedToken = false
        if destinationAddress != toPublicKey.base58EncodedString {
            // check if associated address is already registered
            let info: BufferInfo<AccountInfo>?
            do {
                info = try await getAccountInfoThrowable(account: toPublicKey.base58EncodedString)
            } catch {
                info = nil
            }
            isUnregisteredAsocciatedToken = true

            // if associated token account has been registered
            if info?.owner == TokenProgram.id.base58EncodedString, info?.data != nil {
                isUnregisteredAsocciatedToken = false
            }
        }
        return (destination: toPublicKey, isUnregisteredAsocciatedToken: isUnregisteredAsocciatedToken)
    }

    /// Method retrieves token wallets
    /// - Parameters:
    ///  - account: Public key of an account
    ///  - tokensRepository: Solana token repository,
    /// - Throws: TokenRepositoryError
    /// - Returns array of Wallet
    ///
    func getTokenWallets(account: String, tokensRepository: SolanaTokensRepository? = nil) async throws -> [Wallet] {
        async let accounts = try await getTokenAccountsByOwner(pubkey: account,
                                                               params: .init(
                                                                   mint: nil,
                                                                   programId: TokenProgram.id.base58EncodedString
                                                               ),
                                                               configs: .init(encoding: "base64"))
        let tokensRepository = tokensRepository ?? TokensRepository(endpoint: endpoint)
        async let tokens = try await tokensRepository.getTokensList()
        var knownWallets = [Wallet]()
        var unknownAccounts = [(String, AccountInfo)]()
        let (list, supportedTokens) = (try await accounts, try await tokens)

        for item in list {
            let pubkey = item.pubkey
            let accountInfo = item.account.data

            let mintAddress = accountInfo.mint.base58EncodedString
            // known token
            if let token = supportedTokens.first(where: { $0.address == mintAddress }) {
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
        let mintDatas = try await getMultipleMintDatas(mintAddresses: unknownAccounts.map(\.1.mint.base58EncodedString))
        guard mintDatas.count == unknownAccounts.count else { throw SolanaError.unknown }
        let wallets = mintDatas.enumerated().map {
            Wallet(
                pubkey: unknownAccounts[$0].0,
                lamports: unknownAccounts[$0].1.lamports,
                supply: $1.value.supply,
                token: .unsupported(
                    mint: unknownAccounts[$0].1.mint.base58EncodedString,
                    decimals: $1.value.decimals,
                    supply: $1.value.supply
                )
            )
        }
        return knownWallets + wallets
    }

    /// Wait until transaction is confirmed, return even when there is one or more confirmations and request timed out
    /// - Parameters:
    ///   - signature: signature of the transaction
    ///   - ignoreStatus: ignore status and return true even when observation is timed out
    func waitForConfirmation(signature: String, ignoreStatus: Bool, timeout: Int = 60, delay: Int = 2) async throws {
        var statuses = [TransactionStatus]()
        for try await status in observeSignatureStatus(signature: signature, timeout: timeout, delay: delay) {
            statuses.append(status)
        }

        // if the status is important
        if !ignoreStatus {
            guard let lastStatus = statuses.last else {
                throw SolanaError.transactionHasNotBeenConfirmed
            }
            switch lastStatus {
            case .confirmed, .finalized:
                return
            default:
                throw SolanaError.transactionHasNotBeenConfirmed
            }
        }
    }
    
    /// Returns all information associated with the account of provided Pubkey
    /// - Parameters:
    ///  - account: Pubkey of account to query, as base-58 encoded string
    /// - Throws: APIClientError and SolanaError.couldNotRetrieveAccountInfo
    /// - Returns The result will be an BufferInfo
    /// - SeeAlso https://docs.solana.com/developing/clients/jsonrpc-api#getaccountinfo
    func getAccountInfoThrowable<T: BufferLayout>(account: String) async throws -> BufferInfo<T> {
        let info: BufferInfo<T>? = try await getAccountInfo(account: account)
        guard let info = info else {
            throw SolanaError.couldNotRetrieveAccountInfo
        }
        return info
    }
    
    /// Get fee per signature
    func getLamportsPerSignature() async throws -> UInt64? {
        try await getFees(commitment: nil).feeCalculator?.lamportsPerSignature
    }
    
    /// Convenience method for request(method:params:) with no params
    func request<Entity>(method: String) async throws -> Entity where Entity : Decodable {
        try await request(method: method, params: [])
    }
}
