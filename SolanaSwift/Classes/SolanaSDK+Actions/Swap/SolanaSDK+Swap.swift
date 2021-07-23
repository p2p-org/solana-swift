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
        isSimulation: Bool = false,
        customProxy: SolanaCustomFeeRelayerProxy? = nil
    ) -> Single<SwapResponse> {
        // verify account
        guard let owner = account ?? accountStorage.account
        else {return .error(Error.unauthorized)}
        
        // proxy now support only spl token, disable it when source or destination is WSOL
        var customProxy = customProxy
        if source == owner.publicKey || destination == owner.publicKey {
            customProxy = nil
        }
        
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
            // retrieve pool balance if not exists
            .flatMap {self.getPoolWithTokenBalances(pool: $0)}
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
                // form instructions
                var instructions = [TransactionInstruction]()
                var cleanupInstructions = [TransactionInstruction]()
                
                // create userTransferAuthority
                let userTransferAuthority = try Account(network: self.endpoint.network)
                
                // source
                instructions.append(contentsOf: sourceAccountInstructions.instructions)
                cleanupInstructions.append(contentsOf: sourceAccountInstructions.cleanupInstructions)
                
                // destination
                instructions.append(contentsOf: destinationAccountInstructions.instructions)
                cleanupInstructions.append(contentsOf: destinationAccountInstructions.cleanupInstructions)
                
                // check if new wallet pubkey is created
                var newWalletPubkey: String?
                if destinationAccountInstructions.account != destination {
                    newWalletPubkey = destinationAccountInstructions.account.base58EncodedString
                }
                
                // approve and swap
                let approveAndSwapInstructions = try self.prepareApproveAndSwapInstructions(
                    pool: pool,
                    source: sourceAccountInstructions.account,
                    destination: destinationAccountInstructions.account,
                    userTransferAuthority: userTransferAuthority.publicKey,
                    owner: owner.publicKey,
                    amount: amount,
                    slippage: slippage
                )
                
                instructions.append(contentsOf: approveAndSwapInstructions)
                
                // prepare send request
                let request: Single<TransactionID>
                
                // send to proxy
                if let proxy = customProxy {
                    request = self.swapProxySendTransaction(
                        proxy: proxy,
                        owner: owner.publicKey,
                        userTransferAuthority: userTransferAuthority,
                        pool: pool,
                        source: source,
                        destinationAccountInstructions: destinationAccountInstructions,
                        slippage: slippage,
                        instructions: instructions,
                        cleanupInstructions: cleanupInstructions
                    )
                }
                
                // send without proxy
                else {
                    var signers = [owner, userTransferAuthority]
                    signers.append(contentsOf: sourceAccountInstructions.signers)
                    signers.append(contentsOf: destinationAccountInstructions.signers)
                    
                    request = self.serializeAndSendWithFee(
                        instructions: instructions + cleanupInstructions,
                        signers: signers,
                        isSimulation: isSimulation
                    )
                }
                return request
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
        } catch {
            return .error(error)
        }
    }
    
    private func prepareApproveAndSwapInstructions(
        pool: Pool,
        source: PublicKey,
        destination: PublicKey,
        userTransferAuthority: PublicKey,
        owner: PublicKey,
        amount: Lamports,
        slippage: Double
    ) throws -> [TransactionInstruction] {
        // pool validation
        guard let poolAuthority = pool.authority,
              let estimatedAmount = pool.estimatedAmount(forInputAmount: amount, includeFees: true)
        else { throw Error.other("Swap pool is not valid") }
        let minAmountIn = pool.minimumReceiveAmount(estimatedAmount: estimatedAmount, slippage: slippage)
        
        // TODO: - Host fee
//                let hostFeeAccount = try self.createAccountByMint(
//                    owner: .swapHostFeeAddress,
//                    mint: pool.swapData.tokenPool,
//                    instructions: &instructions,
//                    cleanupInstructions: &cleanupInstructions,
//                    signers: &signers,
//                    minimumBalanceForRentExemption: minimumBalanceForRentExemption
//                )
        
        return [
            TokenProgram.approveInstruction(
                tokenProgramId: .tokenProgramId,
                account: source,
                delegate: userTransferAuthority,
                owner: owner,
                amount: amount
            ),
            TokenSwapProgram.swapInstruction(
                tokenSwap: pool.address,
                authority: poolAuthority,
                userTransferAuthority: userTransferAuthority,
                userSource: source,
                poolSource: pool.swapData.tokenAccountA,
                poolDestination: pool.swapData.tokenAccountB,
                userDestination: destination,
                poolMint: pool.swapData.tokenPool,
                feeAccount: pool.swapData.feeAccount,
                hostFeeAccount: nil,
                swapProgramId: self.endpoint.network.swapProgramId,
                tokenProgramId: .tokenProgramId,
                amountIn: amount,
                minimumAmountOut: minAmountIn
            )
        ]
    }
    
    private func swapProxySendTransaction(
        proxy: SolanaCustomFeeRelayerProxy,
        owner: PublicKey,
        userTransferAuthority: Account,
        pool: Pool,
        source: PublicKey,
        destinationAccountInstructions: AccountInstructions,
        slippage: Double,
        instructions: [TransactionInstruction],
        cleanupInstructions: [TransactionInstruction]
    ) -> Single<TransactionID> {
        // create feepayer wsol account
        let getFeePayerWsolAccount = proxy.getFeePayer()
            .map {try PublicKey(string: $0)}
            .flatMap {
                // create fee payer wsol account
                self.prepareForCreatingTempAccountAndClose(
                    from: owner,
                    amount: 0,
                    payer: $0
                )
            }
        
        // get fee payer and compensation pool
        return Single.zip(
            getFeePayerWsolAccount,
            getMatchedPool(
                sourceMint: pool.swapData.mintA,
                destinationMint: .wrappedSOLMint
            )
        )
            .flatMap { feePayerWsolAccountAndInstructions, feeCompensationPool -> Single<([Account], AccountInstructions, Pool, Lamports)> in
                // form signer
                var signers = [userTransferAuthority]
                signers.append(contentsOf: feePayerWsolAccountAndInstructions.signers)
                
                // fee per signature
                let signatureFeesRequest: Single<Lamports>
                if signers.isEmpty {
                    signatureFeesRequest = .just(0)
                } else {
                    signatureFeesRequest = self.getFees(commitment: nil)
                        .map {$0.feeCalculator?.lamportsPerSignature ?? 0}
                        .map {$0 * Lamports(signers.count)}
                }
                
                // fee per account creation
                let creationFeeRequest: Single<Lamports>
                if destinationAccountInstructions.instructions.isEmpty {
                    creationFeeRequest = .just(0)
                } else {
                    creationFeeRequest = self.getMinimumBalanceForRentExemption(
                        dataLength: UInt64(AccountInfo.BUFFER_LENGTH)
                    )
                }
                
                // total fee
                return Single.zip(
                    signatureFeesRequest,
                    creationFeeRequest
                )
                    .map {$0 + $1}
                    .map {(signers, feePayerWsolAccountAndInstructions, feeCompensationPool, $0)}
            }
        
        .flatMap { (signers, feePayerWsolAccountAndInstructions, feeCompensationPool, feeAmount) -> Single<String> in
            // instructions
            var instructions = instructions
            instructions.append(contentsOf: feePayerWsolAccountAndInstructions.instructions)
            
            instructions.append(contentsOf:
                try self.prepareApproveAndSwapInstructions(
                    pool: feeCompensationPool,
                    source: source,
                    destination: feePayerWsolAccountAndInstructions.account,
                    userTransferAuthority: userTransferAuthority.publicKey,
                    owner: owner,
                    amount: feeAmount,
                    slippage: slippage
                )
            )
            
            // clean up instructions
            var cleanupInstructions = cleanupInstructions
            cleanupInstructions.append(contentsOf: feePayerWsolAccountAndInstructions.cleanupInstructions)
            
            return .just("")
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
