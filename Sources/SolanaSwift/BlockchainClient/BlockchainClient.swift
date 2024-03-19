import Foundation

public enum BlockchainClientError: Error, Equatable {
    case sendTokenToYourSelf
    case invalidAccountInfo
    case other(String)
}

/// Default implementation of SolanaBlockchainClient
public class BlockchainClient: SolanaBlockchainClient {
    public var apiClient: SolanaAPIClient

    public init(apiClient: SolanaAPIClient) {
        self.apiClient = apiClient
    }

    /// Prepare a transaction to be sent using SolanaBlockchainClient
    /// - Parameters:
    ///   - instructions: the instructions of the transaction
    ///   - signers: the signers of the transaction
    ///   - feePayer: the feePayer of the transaction
    ///   - feeCalculator: (Optional) fee custom calculator for calculating fee
    /// - Returns: PreparedTransaction, can be sent or simulated using SolanaBlockchainClient
    public func prepareTransaction(
        instructions: [TransactionInstruction],
        signers: [KeyPair],
        feePayer: PublicKey,
        feeCalculator fc: FeeCalculator? = nil
    ) async throws -> PreparedTransaction {
        // form transaction
        var transaction = Transaction(instructions: instructions, recentBlockhash: nil, feePayer: feePayer)

        let feeCalculator: FeeCalculator
        if let fc = fc {
            feeCalculator = fc
        } else {
            let (lps, minRentExemption) = try await(
                apiClient.getFees(commitment: nil).feeCalculator?.lamportsPerSignature,
                apiClient.getMinimumBalanceForRentExemption(span: 165)
            )
            let lamportsPerSignature = lps ?? 5000
            feeCalculator = DefaultFeeCalculator(
                lamportsPerSignature: lamportsPerSignature,
                minRentExemption: minRentExemption
            )
        }
        let expectedFee = try feeCalculator.calculateNetworkFee(transaction: transaction)

        let blockhash = try await apiClient.getRecentBlockhash()
        transaction.recentBlockhash = blockhash

        // if any signers, sign
        if !signers.isEmpty {
            try transaction.sign(signers: signers)
        }

        // return formed transaction
        return .init(transaction: transaction, signers: signers, expectedFee: expectedFee)
    }

    /// Create prepared transaction for sending SOL
    /// - Parameters:
    ///   - account
    ///   - to: destination wallet address
    ///   - amount: amount in lamports
    ///   - feePayer: customm fee payer, can be omited if the authorized user is the payer
    ///    - recentBlockhash optional
    /// - Returns: PreparedTransaction, can be sent or simulated using SolanaBlockchainClient
    public func prepareSendingNativeSOL(
        from account: KeyPair,
        to destination: String,
        amount: UInt64,
        feePayer: PublicKey? = nil
    ) async throws -> PreparedTransaction {
        let feePayer = feePayer ?? account.publicKey
        let fromPublicKey = account.publicKey
        if fromPublicKey.base58EncodedString == destination {
            throw BlockchainClientError.sendTokenToYourSelf
        }
        var accountInfo: BufferInfo<EmptyInfo>?
        do {
            accountInfo = try await apiClient.getAccountInfo(account: destination)
            guard accountInfo == nil || accountInfo?.owner == SystemProgram.id.base58EncodedString
            else { throw BlockchainClientError.invalidAccountInfo }
        } catch let error as APIClientError where error == .couldNotRetrieveAccountInfo {
            // ignoring error
            accountInfo = nil
        } catch {
            throw error
        }

        // form instruction
        let instruction = try SystemProgram.transferInstruction(
            from: fromPublicKey,
            to: PublicKey(string: destination),
            lamports: amount
        )
        return try await prepareTransaction(
            instructions: [instruction],
            signers: [account],
            feePayer: feePayer
        )
    }

    /// Prepare for sending any SPLToken
    /// - Parameters:
    ///   - account: user's account to send from
    ///   - mintAddress: mint address of sending token
    ///   - decimals: decimals of the sending token
    ///   - fromPublicKey: the concrete spl token address in user's account
    ///   - destinationAddress: the destination address, can be token address or native Solana address
    ///   - amount: amount to be sent
    ///   - feePayer: (Optional) if the transaction would be paid by another user
    ///   - transferChecked: (Default: false) use transferChecked instruction instead of transfer transaction
    ///   - minRentExemption: (Optional) pre-calculated min rent exemption, will be fetched if not provided
    /// - Returns: (preparedTransaction: PreparedTransaction, realDestination: String), preparedTransaction can be sent
    /// or simulated using SolanaBlockchainClient, the realDestination is the real spl address of destination. Can be
    /// different from destinationAddress if destinationAddress is a native Solana address
    public func prepareSendingSPLTokens(
        account: KeyPair,
        mintAddress: String,
        tokenProgramId: PublicKey,
        decimals: Decimals,
        from fromPublicKey: String,
        to destinationAddress: String,
        amount: UInt64,
        feePayer: PublicKey? = nil,
        transferChecked: Bool = false,
        lamportsPerSignature: Lamports,
        minRentExemption: Lamports
    ) async throws -> (preparedTransaction: PreparedTransaction, realDestination: String) {
        let feePayer = feePayer ?? account.publicKey

        let splDestination = try await apiClient.findSPLTokenDestinationAddress(
            mintAddress: mintAddress,
            destinationAddress: destinationAddress,
            tokenProgramId: tokenProgramId
        )

        // get address
        let toPublicKey = splDestination.destination

        // catch error
        if fromPublicKey == toPublicKey.base58EncodedString {
            throw BlockchainClientError.sendTokenToYourSelf
        }

        let fromPublicKey = try PublicKey(string: fromPublicKey)

        var instructions = [TransactionInstruction]()

        // create associated token address
        var accountsCreationFee: UInt64 = 0
        if splDestination.isUnregisteredAsocciatedToken {
            let mint = try PublicKey(string: mintAddress)
            let owner = try PublicKey(string: destinationAddress)

            let createATokenInstruction = try AssociatedTokenProgram.createAssociatedTokenAccountInstruction(
                mint: mint,
                owner: owner,
                payer: feePayer,
                tokenProgramId: tokenProgramId
            )
            instructions.append(createATokenInstruction)
            accountsCreationFee += minRentExemption
        }

        // send instruction
        let sendInstruction: TransactionInstruction

        // use transfer checked transaction for proxy, otherwise use normal transfer transaction
        if transferChecked {
            // transfer checked transaction
            if tokenProgramId == TokenProgram.id {
                sendInstruction = try TokenProgram.transferCheckedInstruction(
                    source: fromPublicKey,
                    mint: PublicKey(string: mintAddress),
                    destination: splDestination.destination,
                    owner: account.publicKey,
                    multiSigners: [],
                    amount: amount,
                    decimals: decimals
                )
            } else {
                sendInstruction = try Token2022Program.transferCheckedInstruction(
                    source: fromPublicKey,
                    mint: PublicKey(string: mintAddress),
                    destination: splDestination.destination,
                    owner: account.publicKey,
                    multiSigners: [],
                    amount: amount,
                    decimals: decimals
                )
            }
        } else {
            // transfer transaction
            if tokenProgramId == TokenProgram.id {
                sendInstruction = TokenProgram.transferInstruction(
                    source: fromPublicKey,
                    destination: toPublicKey,
                    owner: account.publicKey,
                    amount: amount
                )
            } else {
                sendInstruction = Token2022Program.transferInstruction(
                    source: fromPublicKey,
                    destination: toPublicKey,
                    owner: account.publicKey,
                    amount: amount
                )
            }
        }

        instructions.append(sendInstruction)

        var realDestination = destinationAddress
        if !splDestination.isUnregisteredAsocciatedToken {
            realDestination = splDestination.destination.base58EncodedString
        }

        // if not, serialize and send instructions normally
        let preparedTransaction = try await prepareTransaction(
            instructions: instructions,
            signers: [account],
            feePayer: feePayer,
            feeCalculator: DefaultFeeCalculator(
                lamportsPerSignature: lamportsPerSignature,
                minRentExemption: minRentExemption
            )
        )
        return (preparedTransaction, realDestination)
    }
}
