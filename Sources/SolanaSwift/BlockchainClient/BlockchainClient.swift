import Foundation

/// Default implementation of SolanaBlockchainClient
public class BlockchainClient: SolanaBlockchainClient {
    public var apiClient: SolanaAPIClient
    
    public init(apiClient: SolanaAPIClient) {
        self.apiClient = apiClient
    }
    
    public func prepareTransaction(instructions: [TransactionInstruction],
                                   signers: [Account],
                                   feePayer: PublicKey,
                                   recentBlockhash rc: String,
                                   feeCalculator fc: FeeCalculator
    ) async throws -> PreparedTransaction {
        // form transaction
        let transaction = Transaction(instructions: instructions, recentBlockhash: rc, feePayer: feePayer)
        let expectedFee = try fc.calculateNetworkFee(transaction: transaction)
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
    /// - Returns: PreparedTransaction, can be send either directly or via custom fee relayer
    public func prepareSendingNativeSOL(account: Account,
                                        to destination: String,
                                        amount: UInt64,
                                        feePayer: PublicKey? = nil,
                                        recentBlockhash: String,
                                        feeCalculator: FeeCalculator
    ) async throws -> PreparedTransaction {
        let feePayer = feePayer ?? account.publicKey
        let fromPublicKey = account.publicKey
        if fromPublicKey.base58EncodedString == destination {
            throw SolanaError.other("You can not send tokens to yourself")
        }
        var accountInfo: BufferInfo<EmptyInfo>?
        do {
            accountInfo = try await apiClient.getAccountInfo(account: destination)
            guard accountInfo?.owner == SystemProgram.id.base58EncodedString else { throw SolanaError.other("Invalid account info") }
        } catch let error as SolanaError where error == .couldNotRetrieveAccountInfo {
            // ignoring error
            accountInfo = nil
        } catch let error {
            throw error
        }
        
        // form instruction
        let instruction = SystemProgram.transferInstruction(
            from: fromPublicKey,
            to: try PublicKey(string: destination),
            lamports: amount
        )
        return try await prepareTransaction(instructions: [instruction],
                                  signers: [account],
                                  feePayer: feePayer,
                                  recentBlockhash: recentBlockhash,
                                  feeCalculator: feeCalculator)
    }
    
    public func prepareSendingSPLTokens(
        account: Account,
        mintAddress: String,
        decimals: Decimals,
        from fromPublicKey: String,
        to destinationAddress: String,
        amount: UInt64,
        fee: Fee,
        feePayer: PublicKey? = nil,
        transferChecked: Bool = false,
        recentBlockhash: String,
        lamportsPerSignature: Lamports? = nil,
        minRentExemption: Lamports? = nil
    ) async throws -> (preparedTransaction: PreparedTransaction, realDestination: String) {
        let feePayer = feePayer ?? account.publicKey

        let minRentExemptionRequest: Lamports
        if let minRentExemption = minRentExemption {
            minRentExemptionRequest = minRentExemption
        } else {
            minRentExemptionRequest = try await apiClient.getMinimumBalanceForRentExemption(dataLength: AccountInfo.span, commitment: "recent")
        }
        let destinataion = try await findSPLTokenDestinationAddress(mintAddress: mintAddress, destinationAddress: destinationAddress)

        // get address
        let toPublicKey = destinataion.destination

        // catch error
        if fromPublicKey == toPublicKey.base58EncodedString {
            throw SolanaError.other("You can not send tokens to yourself")
        }

        let fromPublicKey = try PublicKey(string: fromPublicKey)

        var instructions = [TransactionInstruction]()

        // create associated token address
        var accountsCreationFee: UInt64 = 0
        if destinataion.isUnregisteredAsocciatedToken {
            let mint = try PublicKey(string: mintAddress)
            let owner = try PublicKey(string: destinationAddress)

            let createATokenInstruction = try AssociatedTokenProgram.createAssociatedTokenAccountInstruction(
                mint: mint,
                owner: owner,
                payer: feePayer
            )
            instructions.append(createATokenInstruction)
            accountsCreationFee += minRentExemptionRequest
        }

        // send instruction
        let sendInstruction: TransactionInstruction

        // use transfer checked transaction for proxy, otherwise use normal transfer transaction
        if transferChecked {
            // transfer checked transaction
            sendInstruction = TokenProgram.transferCheckedInstruction(
                source: fromPublicKey,
                mint: try PublicKey(string: mintAddress),
                destination: destinataion.destination,
                owner: account.publicKey,
                multiSigners: [],
                amount: amount,
                decimals: decimals
            )
        } else {
            // transfer transaction
            sendInstruction = TokenProgram.transferInstruction(
                source: fromPublicKey,
                destination: toPublicKey,
                owner: account.publicKey,
                amount: amount
            )
        }

        instructions.append(sendInstruction)

        var realDestination = destinationAddress
        if !destinataion.isUnregisteredAsocciatedToken {
            realDestination = destinataion.destination.base58EncodedString
        }
        
        guard let lamportsPerSignature = fee.feeCalculator?.lamportsPerSignature ?? lamportsPerSignature else {
            throw SolanaError.other("Either lamportsPerSignature or Fee must be provided")
        }

        // if not, serialize and send instructions normally
        let preparedTx = try await self.prepareTransaction(instructions: instructions,
                                                           signers: [account],
                                                           feePayer: feePayer,
                                                           accountsCreationFee: accountsCreationFee,
                                                           recentBlockhash: recentBlockhash,
                                                           lamportsPerSignature: fee.feeCalculator?.lamportsPerSignature ?? lamportsPerSignature)
        return (preparedTx, realDestination)
    }
    
    public func findSPLTokenDestinationAddress(
        mintAddress: String,
        destinationAddress: String
    ) async throws -> SolanaSDK.SPLTokenDestinationAddress {
        var address: String
        var accountInfo: BufferInfo<AccountInfo>?
        do {
            accountInfo = try await apiClient.getAccountInfo(account: destinationAddress)
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
        } catch let error {
            throw error
        }
        
        //address needs here
        let toPublicKey = try PublicKey(string: address)
        // if destination address is an SOL account address
        var isUnregisteredAsocciatedToken = false
        if destinationAddress != toPublicKey.base58EncodedString {
            // check if associated address is already registered
            let info: BufferInfo<AccountInfo>?
            do {
                info = try await apiClient.getAccountInfo(account: toPublicKey.base58EncodedString)
            } catch {
                info = nil
            }
            isUnregisteredAsocciatedToken = true

            // if associated token account has been registered
            if info?.owner == TokenProgram.id.base58EncodedString && info?.data != nil {
                isUnregisteredAsocciatedToken = false
            }
        }
        return (destination: toPublicKey, isUnregisteredAsocciatedToken: isUnregisteredAsocciatedToken)
    }
    
    public func prepareTransaction(
        instructions: [TransactionInstruction],
        signers: [Account],
        feePayer: PublicKey,
        accountsCreationFee: Lamports,
        recentBlockhash: String,
        lamportsPerSignature: Lamports
    ) async throws -> PreparedTransaction {
        var transaction = Transaction()
        transaction.instructions = instructions
        transaction.recentBlockhash = recentBlockhash
        transaction.feePayer = feePayer

        // calculate fee first
        let expectedFee = FeeAmount(
            transaction: try transaction.calculateTransactionFee(lamportsPerSignatures: lamportsPerSignature),
            accountBalances: accountsCreationFee
        )
        // resign transaction
        try transaction.sign(signers: signers)
        return .init(transaction: transaction, signers: signers, expectedFee: expectedFee)
    }
}
