import Foundation

public extension SolanaBlockchainClient {
    /// Prepare instructions for creating WSOL account and close it after finishing transaction
    /// to return funds back to native SOL account
    /// - Parameters:
    ///   - owner: The owner of new WSOL account
    ///   - amount: The initial amount in Lamports to transfer to the new WSOL account
    ///   - payer: The payer of the transaction (usually the owner)
    ///   - mre: The min rent exemption (leave it nil if there is no pre-defined)
    /// - Returns: AccountInstructions that contains needed instructions, signers, .etc
    func prepareCreatingWSOLAccountAndCloseWhenDone(
        from owner: PublicKey,
        amount: Lamports,
        payer: PublicKey,
        minRentExemption: Lamports
    ) async throws -> AccountInstructions {
        let newAccount = try await KeyPair(network: apiClient.endpoint.network)

        return .init(
            account: newAccount.publicKey,
            instructions: [
                SystemProgram.createAccountInstruction(
                    from: owner,
                    toNewPubkey: newAccount.publicKey,
                    lamports: amount + minRentExemption,
                    space: TokenAccountState.BUFFER_LENGTH,
                    programId: TokenProgram.id
                ),
                TokenProgram.initializeAccountInstruction(
                    account: newAccount.publicKey,
                    mint: .wrappedSOLMint,
                    owner: payer
                ),
            ],
            cleanupInstructions: [
                TokenProgram.closeAccountInstruction(
                    account: newAccount.publicKey,
                    destination: payer,
                    owner: payer
                ),
            ],
            signers: [
                newAccount,
            ],
            secretKey: newAccount.secretKey
        )
    }

    /// Prepare instructions for creating associated token account and close if needed
    /// - Parameters:
    ///   - owner: The owner of new WSOL account
    ///   - mint: The mint of ther token
    ///   - feePayer: The payer of the transaction (usually the owner)
    ///   - closeAfterward: close after done or not
    /// - Returns: AccountInstructions that contains needed instructions, signers, .etc
    func prepareForCreatingAssociatedTokenAccount(
        owner: PublicKey,
        mint: PublicKey,
        tokenProgramId: PublicKey,
        feePayer: PublicKey,
        closeAfterward: Bool
    ) async throws -> AccountInstructions {
        let associatedAddress = try PublicKey.associatedTokenAddress(
            walletAddress: owner,
            tokenMintAddress: mint,
            tokenProgramId: tokenProgramId
        )

        let isAssociatedTokenAddressRegistered: Bool
        do {
            let info: BufferInfo<TokenAccountState>? = try await apiClient
                .getAccountInfo(account: associatedAddress.base58EncodedString)
            if PublicKey.isSPLTokenProgram(info?.owner),
               info?.data.owner == owner
            {
                isAssociatedTokenAddressRegistered = true
            } else {
                throw BlockchainClientError.other("Associated token account is belong to another user")
            }
        } catch {
            if error.isEqualTo(.couldNotRetrieveAccountInfo) {
                isAssociatedTokenAddressRegistered = false
            } else {
                throw error
            }
        }

        // cleanup intructions
        var cleanupInstructions = [TransactionInstruction]()
        if closeAfterward {
            cleanupInstructions = [
                TokenProgram.closeAccountInstruction(
                    account: associatedAddress,
                    destination: owner,
                    owner: owner
                ),
            ]
        }

        // if associated address is registered, there is no need to creating it again
        if isAssociatedTokenAddressRegistered {
            return .init(
                account: associatedAddress,
                cleanupInstructions: []
            )
        }

        // else create associated address
        return try .init(
            account: associatedAddress,
            instructions: [
                AssociatedTokenProgram
                    .createAssociatedTokenAccountInstruction(
                        mint: mint,
                        owner: owner,
                        payer: feePayer,
                        tokenProgramId: tokenProgramId
                    ),
            ],
            cleanupInstructions: cleanupInstructions,
            newWalletPubkey: associatedAddress.base58EncodedString
        )
    }
}
