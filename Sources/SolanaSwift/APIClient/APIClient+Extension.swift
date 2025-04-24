import Foundation

// MARK: - TokenRepository

public extension SolanaAPIClient {
    // MARK: - Convenience methods

    func getTokenAccountsByOwner(
        pubkey: String,
        params: OwnerInfoParams?,
        configs: RequestConfiguration?
    ) async throws -> [TokenAccount<TokenAccountState>] {
        try await getTokenAccountsByOwner(
            pubkey: pubkey,
            params: params,
            configs: configs,
            decodingTo: TokenAccountState.self
        )
    }

    func getMinimumBalanceForRentExemption(span: UInt64) async throws -> UInt64 {
        try await getMinimumBalanceForRentExemption(dataLength: span, commitment: "recent")
    }

    func getRecentBlockhash() async throws -> String {
        try await getRecentBlockhash(commitment: nil)
    }
    
    func getLatestBlockhash() async throws -> String {
        try await getLatestBlockhash(commitment: "processed")
    }

    func observeSignatureStatus(signature: String) -> AsyncStream<PendingTransactionStatus> {
        observeSignatureStatus(signature: signature, timeout: 60, delay: 2)
    }

    /// Get fee per signature
    func getLamportsPerSignature() async throws -> UInt64? {
        try await getFees(commitment: nil).feeCalculator?.lamportsPerSignature
    }

    /// Convenience method for request(method:params:) with no params
    func request<Entity>(method: String) async throws -> Entity where Entity: Decodable {
        try await request(method: method, params: [])
    }

    func getMultipleMintDatas<M: MintLayoutState>(
        mintAddresses: [String],
        commitment: Commitment,
        mintType _: M.Type
    ) async throws -> [String: M] {
        let accounts: [BufferInfo<M>?] = try await getMultipleAccounts(
            pubkeys: mintAddresses,
            commitment: commitment
        )

        var mintDict = [String: M]()

        for (index, address) in mintAddresses.enumerated() {
            let account = accounts[index] as BufferInfo<M>?
            mintDict[address] = account?.data
        }

        return mintDict
    }

    /// Wait until transaction is confirmed, return even when there is one or more confirmations and request timed out
    /// - Parameters:
    ///   - signature: signature of the transaction
    ///   - ignoreStatus: ignore status and return true even when observation is timed out
    func waitForConfirmation(signature: String, ignoreStatus: Bool, timeout: Int = 60, delay: Int = 2) async throws {
        var statuses = [PendingTransactionStatus]()
        for try await status in observeSignatureStatus(signature: signature, timeout: timeout, delay: delay) {
            statuses.append(status)
        }

        // if the status is important
        if !ignoreStatus {
            guard let lastStatus = statuses.last else {
                throw TransactionConfirmationError.unconfirmed
            }
            switch lastStatus {
            case .confirmed, .finalized:
                return
            default:
                throw TransactionConfirmationError.unconfirmed
            }
        }
    }

    // MARK: - Additional methods

    func checkIfAssociatedTokenAccountExists(
        owner: PublicKey,
        mint: String,
        tokenProgramId: PublicKey
    ) async throws -> Bool {
        let mintAddress = try mint.toPublicKey()

        let associatedTokenAccount = try PublicKey.associatedTokenAddress(
            walletAddress: owner,
            tokenMintAddress: mintAddress,
            tokenProgramId: tokenProgramId
        )

        let bufferInfo: BufferInfo<TokenAccountState>? = try await getAccountInfo(account: associatedTokenAccount
            .base58EncodedString)
        return bufferInfo?.data.mint == mintAddress
    }

    /// Method checks account validation
    /// - Parameters:
    ///  - account: Public key of an account
    /// - Throws: TokenRepositoryError
    /// - Returns wether account is valid
    ///
    func checkAccountValidation(account: String) async throws -> Bool {
        try (await getAccountInfo(account: account) as BufferInfo<EmptyInfo>?) != nil
    }

    func findSPLTokenDestinationAddress(
        mintAddress: String,
        destinationAddress: String,
        tokenProgramId: PublicKey
    ) async throws -> SPLTokenDestinationAddress {
        var address: String
        var accountInfo: BufferInfo<TokenAccountState>?
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
                    tokenMintAddress: tokenMint,
                    tokenProgramId: tokenProgramId
                ).base58EncodedString
            } else {
                throw PublicKeyError.invalidAddress(destinationAddress)
            }
        } catch let error as APIClientError where error == .couldNotRetrieveAccountInfo {
            let owner = try PublicKey(string: destinationAddress)
            let tokenMint = try PublicKey(string: mintAddress)
            // create associated token address
            address = try PublicKey.associatedTokenAddress(
                walletAddress: owner,
                tokenMintAddress: tokenMint,
                tokenProgramId: tokenProgramId
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
            let info: BufferInfo<TokenAccountState>?
            do {
                info = try await getAccountInfoThrowable(account: toPublicKey.base58EncodedString)
            } catch {
                info = nil
            }
            isUnregisteredAsocciatedToken = true

            // if associated token account has been registered
            if PublicKey.isSPLTokenProgram(info?.owner),
               info?.data != nil
            {
                isUnregisteredAsocciatedToken = false
            }
        }
        return (destination: toPublicKey, isUnregisteredAsocciatedToken: isUnregisteredAsocciatedToken)
    }

    /// Returns all information associated with the account of provided Pubkey
    /// - Parameters:
    ///  - account: Pubkey of account to query, as base-58 encoded string
    /// - Throws: APIClientError
    /// - Returns The result will be an BufferInfo
    /// - SeeAlso https://docs.solana.com/developing/clients/jsonrpc-api#getaccountinfo
    func getAccountInfoThrowable<T: BufferLayout>(account: String) async throws -> BufferInfo<T> {
        let info: BufferInfo<T>? = try await getAccountInfo(account: account)
        guard let info = info else {
            throw APIClientError.couldNotRetrieveAccountInfo
        }
        return info
    }
}
