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
                                   feeCalculator fc: FeeCalculator? = nil
    ) async throws -> PreparedTransaction {
        // form transaction
        let transaction = Transaction(instructions: instructions, recentBlockhash: nil, feePayer: feePayer)
        
        let feeCalculator: FeeCalculator
        if let fc = fc {
            feeCalculator = fc
        } else {
            let (lps, minRentExemption) = try await (
                apiClient.getFees(commitment: nil).feeCalculator?.lamportsPerSignature,
                apiClient.getMinimumBalanceForRentExemption(span: 165)
            )
            let lamportsPerSignature = lps ?? 5000
            feeCalculator = DefaultFeeCalculator(lamportsPerSignature: lamportsPerSignature, minRentExemption: minRentExemption)
        }
        let expectedFee = try feeCalculator.calculateNetworkFee(transaction: transaction)
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
    public func prepareSendingNativeSOL(from account: Account,
                                        to destination: String,
                                        amount: UInt64,
                                        feePayer: PublicKey? = nil
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
                                  feePayer: feePayer)
    }
    
    public func prepareSendingSPLTokens(
        account: Account,
        mintAddress: String,
        decimals: Decimals,
        from fromPublicKey: String,
        to destinationAddress: String,
        amount: UInt64,
        feePayer: PublicKey? = nil,
        transferChecked: Bool = false,
        lamportsPerSignature: Lamports? = nil,
        minRentExemption mre: Lamports? = nil
    ) async throws -> (preparedTransaction: PreparedTransaction, realDestination: String) {
        let feePayer = feePayer ?? account.publicKey

        let minRenExemption: Lamports
        if let mre = mre {
            minRenExemption = mre
        } else {
            minRenExemption = try await apiClient.getMinimumBalanceForRentExemption(span: AccountInfo.BUFFER_LENGTH)
        }
        let splDestination = try await apiClient.findSPLTokenDestinationAddress(mintAddress: mintAddress, destinationAddress: destinationAddress)

        // get address
        let toPublicKey = splDestination.destination

        // catch error
        if fromPublicKey == toPublicKey.base58EncodedString {
            throw SolanaError.other("You can not send tokens to yourself")
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
                payer: feePayer
            )
            instructions.append(createATokenInstruction)
            accountsCreationFee += minRenExemption
        }

        // send instruction
        let sendInstruction: TransactionInstruction

        // use transfer checked transaction for proxy, otherwise use normal transfer transaction
        if transferChecked {
            // transfer checked transaction
            sendInstruction = TokenProgram.transferCheckedInstruction(
                source: fromPublicKey,
                mint: try PublicKey(string: mintAddress),
                destination: splDestination.destination,
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
        if !splDestination.isUnregisteredAsocciatedToken {
            realDestination = splDestination.destination.base58EncodedString
        }

        // if not, serialize and send instructions normally
        let preparedTransaction = try await prepareTransaction(
            instructions: instructions,
            signers: [account],
            feePayer: feePayer
        )
        return (preparedTransaction, realDestination)
    }
}
