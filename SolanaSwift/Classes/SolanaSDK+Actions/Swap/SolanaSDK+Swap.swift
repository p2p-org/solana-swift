//
//  SolanaSDK+Swap.swift
//  SolanaSwift
//
//  Created by Chung Tran on 21/01/2021.
//

import Foundation
import RxSwift

extension SolanaSDK {
    public struct SwapResponse {
        public let transactionId: String
        public let newWalletPubkey: String?
    }
    
    struct AccountInstructions {
        let account: PublicKey
        let instructions: [TransactionInstruction]
        let cleanupInstructions: [TransactionInstruction]
        let signers: [Account]
    }
    
    public func swap(
        account: Account? = nil,
        pool: Pool? = nil,
        source: PublicKey,
        sourceMint: PublicKey,
        destination: PublicKey? = nil,
        destinationMint: PublicKey,
        slippage: Double,
        amount: UInt64,
        isSimulation: Bool = false
    ) -> Single<SwapResponse> {
        // verify account
        guard let owner = account ?? accountStorage.account
        else {return .error(Error.unauthorized)}
        
        // payer
        let payer = owner
        
        // get pool pools
        let getPoolRequest: Single<Pool>
        if let pool = pool {
            getPoolRequest = .just(pool)
        } else {
            getPoolRequest = getMatchedPool(
                sourceMint: sourceMint,
                destinationMint: destinationMint
            )
        }
        
        // get pool
        return getPoolRequest
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .flatMap { pool in
                Single.zip(
                    .just(pool),
                    
                    self.prepareSourceAccountAndInstructions(
                        pool: pool,
                        source: source,
                        amount: amount,
                        payer: owner.publicKey
                    ),
                    
                    self.prepareDestinationAccountAndInstructions(
                        myAccount: owner.publicKey,
                        destination: destination,
                        destinationMint: destinationMint,
                        payer: payer
                    )
                )
            }
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .flatMap { pool, sourceAccountInstructions, destinationAccountInstructions in
                // pool validation
                guard let poolAuthority = pool.authority,
                      let estimatedAmount = pool.estimatedAmount(forInputAmount: amount, includeFees: true),
                      let tokenBBalance = UInt64(pool.tokenBBalance?.amount ?? "")
                else {return .error(Error.other("Swap pool is not valid"))}
                let minAmountIn = pool.minimumReceiveAmount(estimatedAmount: estimatedAmount, slippage: slippage)
                
                // form instructions
                var instructions = [TransactionInstruction]()
                var cleanupInstructions = [TransactionInstruction]()
                
                // form signers
                let userTransferAuthority = try Account(network: self.endpoint.network)
                var signers = [owner, userTransferAuthority]
                
                // source
                instructions.append(contentsOf: sourceAccountInstructions.instructions)
                cleanupInstructions.append(contentsOf: sourceAccountInstructions.cleanupInstructions)
                signers.append(contentsOf: sourceAccountInstructions.signers)
                
                // destination
                instructions.append(contentsOf: destinationAccountInstructions.instructions)
                cleanupInstructions.append(contentsOf: destinationAccountInstructions.cleanupInstructions)
                signers.append(contentsOf: destinationAccountInstructions.signers)
                
                // check if new wallet pubkey is created
                var newWalletPubkey: String?
                if destinationAccountInstructions.account != destination {
                    newWalletPubkey = destinationAccountInstructions.account.base58EncodedString
                }
                
                // approve
                instructions.append(
                    TokenProgram.approveInstruction(
                        tokenProgramId: .tokenProgramId,
                        account: sourceAccountInstructions.account,
                        delegate: userTransferAuthority.publicKey,
                        owner: owner.publicKey,
                        amount: amount
                    )
                )
                
                // TODO: - Host fee
//                let hostFeeAccount = try self.createAccountByMint(
//                    owner: .swapHostFeeAddress,
//                    mint: pool.swapData.tokenPool,
//                    instructions: &instructions,
//                    cleanupInstructions: &cleanupInstructions,
//                    signers: &signers,
//                    minimumBalanceForRentExemption: minimumBalanceForRentExemption
//                )
                
                // swap
                instructions.append(
                    TokenSwapProgram.swapInstruction(
                        tokenSwap: pool.address,
                        authority: poolAuthority,
                        userTransferAuthority: userTransferAuthority.publicKey,
                        userSource: sourceAccountInstructions.account,
                        poolSource: pool.swapData.tokenAccountA,
                        poolDestination: pool.swapData.tokenAccountB,
                        userDestination: destinationAccountInstructions.account,
                        poolMint: pool.swapData.tokenPool,
                        feeAccount: pool.swapData.feeAccount,
                        hostFeeAccount: nil,
                        swapProgramId: self.endpoint.network.swapProgramId,
                        tokenProgramId: .tokenProgramId,
                        amountIn: amount,
                        minimumAmountOut: minAmountIn
                    )
                )
                
                return self.serializeAndSendWithFee(
                    instructions: instructions + cleanupInstructions,
                    signers: signers,
                    isSimulation: isSimulation
                )
                    .map {.init(transactionId: $0, newWalletPubkey: newWalletPubkey)}
            }
    }
    
    // MARK: - Get pools
    func getMatchedPool(
        sourceMint: PublicKey,
        destinationMint: PublicKey
    ) -> Single<Pool> {
        getSwapPools()
            .map {pools -> Pool in
                // filter pool that match requirement
                if let matchPool = pools.matchedPool(
                    sourceMint: sourceMint.base58EncodedString,
                    destinationMint: destinationMint.base58EncodedString
                ) {
                    return matchPool
                }
                throw Error.other("Unsupported swapping tokens")
            }
    }
    
    // MARK: - Account and instructions
    func prepareSourceAccountAndInstructions(
        pool: Pool,
        source: PublicKey,
        amount: Lamports,
        payer: PublicKey
    ) -> Single<AccountInstructions> {
        getAccountInfo(
            account: pool.swapData.tokenAccountA.base58EncodedString,
            decodedTo: AccountInfo.self
        )
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            // check if source token is native
            .map { info -> Bool in
                guard info.owner == PublicKey.tokenProgramId.base58EncodedString,
                      let isNative = info.data.value?.isNative
                else {
                    throw Error.other("Source account is not valid")
                }
                
                return isNative
            }
            // create token if source token is native
            .flatMap {isNative in
                // if token is non-native
                if !isNative {
                    return .just(.init(
                        account: source,
                        instructions: [],
                        cleanupInstructions: [],
                        signers: []
                    ))
                }
                
                // if token is native
                return self.prepareForCreatingTempAccountAndClose(
                    from: source,
                    amount: amount,
                    payer: payer
                )
            }
    }
    
    func prepareDestinationAccountAndInstructions(
        myAccount: PublicKey,
        destination: PublicKey?,
        destinationMint: PublicKey,
        payer: Account
    ) -> Single<AccountInstructions> {
        // if destination is a registered non-native token account
        if let destination = destination, destination != myAccount
        {
            return .just(
                .init(
                    account: destination,
                    instructions: [],
                    cleanupInstructions: [],
                    signers: []
                )
            )
        }
        
        // if destination is a native account or is nil
        return prepareForCreatingAssociatedTokenAccountAndCloseIfNative(
            owner: myAccount,
            mint: destinationMint,
            payer: payer
        )
    }
    
    // MARK: - Helpers
    private func prepareForCreatingTempAccountAndClose(
        from source: PublicKey,
        amount: Lamports,
        payer: PublicKey
    ) -> Single<AccountInstructions> {
        getMinimumBalanceForRentExemption(
            dataLength: UInt64(AccountInfo.BUFFER_LENGTH)
        )
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .map { minimumBalanceForRentExemption in
                // create new account
                let newAccount = try Account(network: self.endpoint.network)
                
                return .init(
                    account: newAccount.publicKey,
                    instructions: [
                        SystemProgram.createAccountInstruction(
                            from: source,
                            toNewPubkey: newAccount.publicKey,
                            lamports: amount + minimumBalanceForRentExemption
                        ),
                        TokenProgram.initializeAccountInstruction(
                            account: newAccount.publicKey,
                            mint: .wrappedSOLMint,
                            owner: payer
                        )
                    ],
                    cleanupInstructions: [
                        TokenProgram.closeAccountInstruction(
                            account: newAccount.publicKey,
                            destination: payer,
                            owner: payer
                        )
                    ],
                    signers: [
                        newAccount
                    ]
                )
            }
    }
    
    private func prepareForCreatingAssociatedTokenAccountAndCloseIfNative(
        owner: PublicKey,
        mint: PublicKey,
        payer: Account
    ) -> Single<AccountInstructions> {
        do {
            let associatedAddress = try PublicKey.associatedTokenAddress(
                walletAddress: owner,
                tokenMintAddress: mint
            )
            
            return getAccountInfo(
                account: associatedAddress.base58EncodedString,
                decodedTo: AccountInfo.self
            )
                .observe(on: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
                // check if associated address is registered
                .map { info -> Bool in
                    if info.owner == PublicKey.tokenProgramId.base58EncodedString,
                       info.data.value?.owner == owner
                    {
                        return true
                    }
                    throw Error.other("Associated token account is belong to another user")
                }
                .catch { error in
                    // associated address is not available
                    if let error = error as? Error,
                       error == Error.other("Could not retrieve account info")
                    {
                        return .just(false)
                    }
                    throw error
                }
                .map {isRegistered -> AccountInstructions in
                    // cleanup intructions
                    var cleanupInstructions = [TransactionInstruction]()
                    if mint == .wrappedSOLMint {
                        cleanupInstructions = [
                            TokenProgram.closeAccountInstruction(
                                account: associatedAddress,
                                destination: owner,
                                owner: owner
                            )
                        ]
                    }
                    
                    // if associated address is registered, there is no need to creating it again
                    if isRegistered {
                        return .init(
                            account: associatedAddress,
                            instructions: [],
                            cleanupInstructions: cleanupInstructions,
                            signers: []
                        )
                    }
                    
                    // create associated address
                    return .init(
                        account: associatedAddress,
                        instructions: [
                            AssociatedTokenProgram
                                .createAssociatedTokenAccountInstruction(
                                    mint: mint,
                                    associatedAccount: associatedAddress,
                                    owner: owner,
                                    payer: payer.publicKey
                                )
                        ],
                        cleanupInstructions: cleanupInstructions,
                        signers: []
                    )
                }
                .catch {error -> Single<AccountInstructions> in
                    if let error = error as? Error,
                       error == .other("Associated token account is belong to another user")
                    {
                        return self.prepareForCreatingTempAccountAndClose(
                            from: owner,
                            amount: 0,
                            payer: payer.publicKey
                        )
                    }
                    throw error
                }
        } catch {
            return .error(error)
        }
    }
    
//    private func createAccountByMint(
//        owner: PublicKey,
//        mint: PublicKey,
//        instructions: inout [TransactionInstruction],
//        cleanupInstructions: inout [TransactionInstruction],
//        signers: inout [Account],
//        minimumBalanceForRentExemption: UInt64
//    ) throws -> Account {
//        let newAccount = try Account(network: endpoint.network)
//
//        instructions.append(
//            SystemProgram.createAccountInstruction(
//                from: owner,
//                toNewPubkey: newAccount.publicKey,
//                lamports: minimumBalanceForRentExemption
//            )
//        )
//
//        instructions.append(
//            TokenProgram.initializeAccountInstruction(
//                account: newAccount.publicKey,
//                mint: mint,
//                owner: owner
//            )
//        )
//
//        if mint == .wrappedSOLMint {
//            cleanupInstructions.append(
//                TokenProgram.closeAccountInstruction(
//                    account: newAccount.publicKey,
//                    destination: owner,
//                    owner: owner
//                )
//            )
//        }
//
//        signers.append(newAccount)
//        return newAccount
//    }
}
