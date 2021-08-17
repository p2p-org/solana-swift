//
//  SerumSwap.swift
//  SolanaSwift
//
//  Created by Chung Tran on 09/08/2021.
//

import Foundation
import RxSwift

// Close account feature flag.
//
// TODO: enable once the DEX supports closing open orders accounts.
let CLOSE_ENABLED = false;

// Initialize open orders feature flag.
//
// TODO: enable once the DEX supports initializing open orders accounts.
let OPEN_ENABLED = false;

public struct SerumSwap {
    // MARK: - Properties
    let client: SerumSwapAPIClient
    let accountProvider: SerumSwapAccountProvider
    let swapMarkets: SwapMarkets
    
    // MARK: - Initializers
    public init(
        client: SerumSwapAPIClient,
        accountProvider: SerumSwapAccountProvider,
        tokenListContainer: SerumSwapTokenListContainer
    ) {
        self.client = client
        self.accountProvider = accountProvider
        self.swapMarkets = SwapMarkets(tokenListContainer: tokenListContainer)
    }
    
    // MARK: - Methods
    /// Returns a list of markets to trade across to swap `fromMint` to `toMint`.
    public func route(fromMint: PublicKey, toMint: PublicKey) -> Single<[PublicKey]?> {
        swapMarkets.route(fromMint: fromMint, toMint: toMint)
    }
    
    // MARK: - InitAccount
    /**
     * Sends a transaction to initialize all accounts required for a swap between
     * the two mints. I.e., creates the DEX open orders accounts.
     *
     * @throws if all open orders accounts already exist.
     */
    public func initAccounts(
        fromMint: PublicKey,
        toMint: PublicKey
    ) -> Single<SignersAndInstructions> {
        
        // Direct swap on USD(x).
        if fromMint == .usdcMint || fromMint == .usdtMint {
            return createAndInitAccountForDirectSwapOnUSDX(
                fromMint: fromMint,
                toMint: toMint
            )
        }
        else if toMint == .usdcMint || toMint == .usdtMint {
            return createAndInitAccountForDirectSwapOnUSDX(
                fromMint: toMint,
                toMint: fromMint
            )
        }
        // Transitive swap across USD(x).
        else {
            // Builds the instructions for initializing open orders for a transitive swap.
            // Build transitive with usdcMint
            return buildTransitiveForInitAccounts(
                usdxMint: .usdcMint,
                fromMint: fromMint,
                toMint: toMint
            )
            .catch {_ in
                // Retry with building transitive with usdtMint
                return self.buildTransitiveForInitAccounts(
                    usdxMint: .usdtMint,
                    fromMint: fromMint,
                    toMint: toMint
                )
            }
        }
    }
    
    private func createAndInitAccountForDirectSwapOnUSDX(
        fromMint: PublicKey,
        toMint: PublicKey
    ) -> Single<SignersAndInstructions>
    {
        
        client.getMarketAddressIfNeeded(
            usdxMint: fromMint,
            baseMint: toMint
        )
        .flatMap { marketAddress in
            createAndInitAccount(marketAddress: marketAddress)
        }
    }
    
    private func buildTransitiveForInitAccounts(
        usdxMint: PublicKey,
        fromMint: PublicKey,
        toMint: PublicKey
    ) -> Single<SignersAndInstructions> {
        
        findMarketsAndOpenOrders(
            usdxMint: usdxMint,
            fromMint: fromMint,
            toMint: toMint
        )
            .flatMap { marketFrom, marketTo, ooAccsFrom, ooAccsTo  in
                
                
                if ooAccsFrom.first != nil && ooAccsTo.first != nil {
                    throw SerumSwapError("Open orders already exist")
                }
                
                if ooAccsFrom.first == nil {
                    return self.createAndInitAccount(marketAddress: marketFrom)
                }
                
                if ooAccsTo.first == nil {
                    return self.createAndInitAccount(marketAddress: marketTo)
                }
                
                throw SerumSwapError.unknown
            }
    }
    
    private func createAndInitAccount(
        marketAddress: PublicKey
    ) -> Single<SignersAndInstructions> {
        // create new account
        let newAccount: Account
        do {
            newAccount = try Account(network: .mainnetBeta)
        } catch {
            return .error(error)
        }
        
        guard let ownerAddress = accountProvider.getNativeWalletAddress()
        else {
            return .error(SerumSwapError.unauthorized)
        }
        
        // form instruction
        return OpenOrders.makeCreateAccountInstruction(
            client: client,
            marketAddress: marketAddress,
            ownerAddress: ownerAddress,
            newAccountAddress: newAccount.publicKey,
            programId: .dexPID
        )
        .map {createAccountInstruction in
            
            var instructions = [createAccountInstruction]
            instructions.append(
                self.initAccountInstruction(
                    order: newAccount.publicKey,
                    marketAddress: marketAddress
                )
            )
            let signers = [newAccount]
            return .init(signers: signers, instructions: instructions)
        }
    }
    
    // MARK: - CloseAccount
    /**
     * Sends a transaction to close all accounts required for a swap transaction,
     * i.e., all currently open DEX open orders accounts for the given `fromMint`
     * `toMint` swap path.
     *
     * @throws if no open orders accounts exist.
     */
    public func closeAccounts(
        fromMint: PublicKey,
        toMint: PublicKey
    ) -> Single<SignersAndInstructions> {
        let instructionRequest: Single<TransactionInstruction>
        
        if fromMint == .usdcMint || fromMint == .usdtMint {
            instructionRequest = closeAccountForDirectSwapOnUSDX(
                fromMint: fromMint,
                toMint: toMint
            )
        }
        else if toMint == .usdcMint || toMint == .usdtMint {
            instructionRequest = closeAccountForDirectSwapOnUSDX(
                fromMint: toMint,
                toMint: fromMint
            )
        }
        // Transitive swap across USD(x).
        else {
            instructionRequest = buildTransitiveForCloseAccount(
                usdxMint: .usdcMint,
                fromMint: fromMint,
                toMint: toMint
            )
            .catch {_ in
                // Retry with building transitive with usdtMint
                buildTransitiveForCloseAccount(
                    usdxMint: .usdtMint,
                    fromMint: fromMint,
                    toMint: toMint
                )
            }
        }
        
        return instructionRequest
            .map {instruction in
                return .init(
                    signers: [],
                    instructions: [instruction]
                )
            }
    }
    
    private func buildTransitiveForCloseAccount(
        usdxMint: PublicKey,
        fromMint: PublicKey,
        toMint: PublicKey
    ) -> Single<TransactionInstruction> {
        
        findMarketsAndOpenOrders(
            usdxMint: usdxMint,
            fromMint: fromMint,
            toMint: toMint
        )
        .map { marketFrom, marketTo, ooAccsFrom, ooAccsTo  in
            
            guard let owner = self.accountProvider.getNativeWalletAddress() else {throw SerumSwapError.unauthorized}
            
            if ooAccsFrom.first == nil && ooAccsTo.first == nil {
                throw SerumSwapError("No open orders accounts left to close")
            }
            if let order = ooAccsFrom.first {
                return self.closeAccountInstruction(order: order.address, marketAddress: marketFrom, owner: owner)
            }
            
            if let order = ooAccsTo.first {
                return self.closeAccountInstruction(order: order.address, marketAddress: marketTo, owner: owner)
            }
            
            throw SerumSwapError.unknown
        }
    }
    
    private func closeAccountForDirectSwapOnUSDX(
        fromMint: PublicKey,
        toMint: PublicKey
    ) -> Single<TransactionInstruction>
    {
        guard let ownerAddress = self.accountProvider.getNativeWalletAddress()
        else {return .error(SerumSwapError.unauthorized)}
        
        return client.getMarketAddress(usdxMint: fromMint, baseMint: toMint)
            .flatMap {marketAddress -> Single<([OpenOrders], PublicKey)> in
                
                return Single.zip(
                    OpenOrders.findForMarketAndOwner(
                        client: self.client,
                        marketAddress: marketAddress,
                        ownerAddress: ownerAddress,
                        programId: .dexPID
                    ),
                    .just(marketAddress)
                )
            }
            .map {openOrders, marketAddress in
                
                guard let owner = self.accountProvider.getNativeWalletAddress() else {throw SerumSwapError.unauthorized}
                guard let order = openOrders.first else {throw SerumSwapError("Open orders account doesn't exist")}
                return self.closeAccountInstruction(order: order.publicKey, marketAddress: marketAddress, owner: owner)
            }
    }
    
    // MARK: - Swap
    /**
     * Executes a swap against the Serum DEX on Solana. When using one should
     * first use `estimate` along with a user defined error tolerance to calculate
     * the `minExpectedSwapAmount`, which provides a lower bound for the number
     * of output tokens received when executing the swap. If, for example,
     * swapping on an illiquid market and the output tokens is less than
     * `minExpectedSwapAmount`, then the transaction will fail in an attempt to
     * prevent an undesireable outcome.
     */
    /// - Parameters:
    ///   - fromMint: Token mint to swap from.
    ///   - toMint: Token mint to swap to.
    ///   - amount: Amount of `fromMint` to swap in exchange for `toMint`.
    ///   - minExpectedSwapAmount: The minimum number of `toMint` tokens one should receive for the swap. This is a safety mechanism to prevent one from performing an unexpecteed trade. If not given, then defaults to 0.05% off the **estimated** amount.
    ///   - referral: Token account to receive the Serum referral fee. The mint must be in the quote currency of the trade.
    ///   - quoteWallet: Wallet of the quote currency to use in a transitive swap. Should be either a USDC or USDT wallet. If not provided uses an associated token address for the configured provider.
    ///   - fromWallet: Wallet for `fromMint`. If not provided, uses an associated token address for the configured provider.
    ///   - toWallet: Wallet for `toMint`. If not provided, uses the associated token address for the configured provider.
    ///   - feePayer: The wallet that is responsible for paying fee (leave it nil if user is the payer)
    ///   - configs: Request configuration.
    public func swap(_ params: SwapParams) -> Single<SignersAndInstructions> {
        // TODO: - fee relayer
        prepareForSwap(params)
    }
    
    /**
     * Returns an estimate for the number of *to*, i.e., output, tokens one would
     * get for the given swap parameters. This is useful to inform the user
     * approximately what will happen if the user executes the swap trade. UIs
     * should use this in conjunction with some bound (e.g. 5%), to prevent users
     * from making unexpected trades.
     */
    public func estimate(_ params: SwapParams) -> Single<Lamports> {
        // Build the transaction.
        var params = params
        params.minExpectedSwapAmount = 1
        return prepareForSwap(params)
            .flatMap {signersAndInstructions -> Single<String> in
                
                return self.client.serializeTransaction(
                    instructions: signersAndInstructions.instructions,
                    recentBlockhash: nil,
                    signers: signersAndInstructions.signers,
                    feePayer: params.feePayer
                )
            }
            .flatMap {transaction -> Single<Lamports> in
                
                return self.client.simulateTransaction(transaction: transaction)
                    .map {$0.logs}
                    .map {logs -> DidSwap in
                        guard let log = logs.first(where: {$0.starts(with: "Program log: 4ZfIrPLY4R'")})?
                                .replacingOccurrences(of: "Program log: ", with: ""),
                              let data = Data(base64Encoded: log)?[8...] // logArr.slice(8)
                        else {throw SerumSwapError("Could not estimate minimum expected amount")}
                        return try DidSwap(buffer: data)
                    }
                    .map {$0.toAmount}
            }
        
    }
    
    private func prepareForSwap(_ params: SwapParams) -> Single<SignersAndInstructions> {
        guard let owner = accountProvider.getNativeWalletAddress()
        else {return .error(SerumSwapError.unauthorized)}
        
        // min expected swap amount
        let requestMinExpectedSwapAmount: Single<Lamports>
        if let minExpectedSwapAmount = params.minExpectedSwapAmount {
            requestMinExpectedSwapAmount = .just(minExpectedSwapAmount)
        } else {
            requestMinExpectedSwapAmount = estimate(params)
                .map {estimated in
                    // Defaults to 0.5% error off the estimate, if not provided.
                    SerumSwap.Lamports(BInt(estimated) * BInt(995) / BInt(1000))
                }
        }
        
        // Prepare source account, create and init new account if fromWallet is native.
        let requestSourceAccount = client.prepareSourceAccountAndInstructions(
            myNativeWallet: owner,
            source: params.fromWallet,
            sourceMint: params.fromMint,
            amount: params.amount,
            feePayer: params.feePayer ?? owner
        )
        
        // Prepare destination account, create associated token if toWallet is native.
        let requestDestinationAccount = client.prepareDestinationAccountAndInstructions(
            myAccount: owner,
            destination: params.toWallet,
            destinationMint: params.toMint,
            feePayer: params.feePayer ?? owner
        )
        
        // Swap
        return Single.zip(
            requestMinExpectedSwapAmount,
            requestSourceAccount,
            requestDestinationAccount
        )
        .flatMap {minExpectedSwapAmount, sourceAccountInstructions, destinationAccountInstructions in
            let signers = sourceAccountInstructions.signers + destinationAccountInstructions.signers
            let instructions = sourceAccountInstructions.instructions + destinationAccountInstructions.instructions
            let cleanupInstructions = sourceAccountInstructions.cleanupInstructions + destinationAccountInstructions.cleanupInstructions
            
            // If swapping to/from a USD(x) token, then swap directly on the market.
            if params.fromMint == .usdcMint || params.fromMint == .usdtMint {
                return self.swapDirect(
                    coinWallet: destinationAccountInstructions.account,
                    pcWallet: sourceAccountInstructions.account,
                    baseMint: params.toMint,
                    quoteMint: params.fromMint,
                    side: .bid,
                    amount: params.amount,
                    minExpectedSwapAmount: minExpectedSwapAmount,
                    referral: params.referral,
                    currentSigners: signers,
                    currentInstructions: instructions,
                    cleanupInstructions: cleanupInstructions
                )
            }
            else if params.toMint == .usdcMint || params.toMint == .usdtMint {
                return self.swapDirect(
                    coinWallet: sourceAccountInstructions.account,
                    pcWallet: destinationAccountInstructions.account,
                    baseMint: params.fromMint,
                    quoteMint: params.toMint,
                    side: .ask,
                    amount: params.amount,
                    minExpectedSwapAmount: minExpectedSwapAmount,
                    referral: params.referral,
                    currentSigners: signers,
                    currentInstructions: instructions,
                    cleanupInstructions: cleanupInstructions
                )
            }
            
            // Neither wallet is a USD stable coin. So perform a transitive swap.
            let requestQuoteWallet: Single<PublicKey>
            if let quoteWallet = params.quoteWallet {
                requestQuoteWallet = .just(quoteWallet)
            } else {
                requestQuoteWallet = self.client.usdcPathExists(
                    fromMint: params.fromMint,
                    toMint: params.toMint
                )
                .map { usdcPathExists in
                    if usdcPathExists {
                        return try PublicKey.associatedTokenAddress(
                            walletAddress: owner,
                            tokenMintAddress: .usdcMint
                        )
                    } else {
                        return try PublicKey.associatedTokenAddress(
                            walletAddress: owner,
                            tokenMintAddress: .usdtMint
                        )
                    }
                }
            }
            
            return requestQuoteWallet
                .flatMap {quoteWallet in
                    swapTransitive(
                        fromMint: params.fromMint,
                        toMint: params.toMint,
                        fromWallet: sourceAccountInstructions.account,
                        toWallet: destinationAccountInstructions.account,
                        pcWallet: quoteWallet,
                        amount: params.amount,
                        minExpectedSwapAmount: minExpectedSwapAmount,
                        referral: params.referral,
                        currentSigners: signers,
                        currentInstructions: instructions,
                        cleanupInstructions: cleanupInstructions
                    )
                }
            
        }
    }
    
    private func swapDirect(
        coinWallet: PublicKey,
        pcWallet: PublicKey,
        baseMint: PublicKey,
        quoteMint: PublicKey,
        side: Side,
        amount: Lamports,
        minExpectedSwapAmount: Lamports,
        referral: PublicKey?,
        currentSigners: [Account],
        currentInstructions: [TransactionInstruction],
        cleanupInstructions: [TransactionInstruction]
    ) -> Single<SignersAndInstructions> {
        
        client.getMarketAddresses(
            usdxMint: quoteMint,
            baseMint: baseMint
        )
            .flatMap {marketAddresses -> Single<(Market, UInt64)> in
                
                return Single.zip(
                    Market.loadAndFindValidMarket(client: self.client, addresses: marketAddresses, programId: .dexPID),
                    OpenOrders.getMinimumBalanceForRentExemption(client: self.client, programId: .dexPID)
                )
            }
            .flatMap {marketClient, minRemExemption -> Single<(Market, PublicKey, GetOpenOrderResult)> in
                
                
                guard let owner = self.accountProvider.getNativeWalletAddress()
                else {throw SerumSwapError.unauthorized}
                
                return Single.zip(
                    .just(marketClient),
                    Self.getVaultOwnerAndNonce(
                        marketPublicKey: marketClient.address,
                        dexProgramId: .dexPID
                    ).map {$0.vaultOwner},
                    OpenOrders.findAnOpenOrderOrCreateOne(
                        client: self.client,
                        marketAddress: marketClient.address,
                        ownerAddress: owner,
                        programId: .dexPID,
                        minRentExemption: minRemExemption
                    )
                )
            }
            .map {market, vaultOwner, order -> SignersAndInstructions in
                
                guard let openOrder = order.existingOpenOrder ?? order.newOpenOrder?.signers.first?.publicKey
                else {throw SerumSwapError("Could not find or create new order")}
                guard let authority = self.accountProvider.getNativeWalletAddress()
                else { throw SerumSwapError.unauthorized }
                
                var signers = currentSigners
                var instructions = currentInstructions
                var cleanupInstructions = cleanupInstructions
                
                if let newOrder = order.newOpenOrder {
                    signers += newOrder.signers
                    instructions += newOrder.instructions
                    
                    // TODO: - uncomment once the DEX supports closing open orders accounts.
//                    cleanupInstructions.append(
//                        self.closeAccountInstruction(
//                            order: openOrder,
//                            marketAddress: market.address
//                        )
//                    )
                }
                
                // add swap instruction
                instructions.append(
                    self.directSwapInstruction(authority: authority, side: side, amount: amount, minExpectedSwapAmount: minExpectedSwapAmount, market: market, vaultSigner: vaultOwner, openOrders: openOrder, pcWallet: pcWallet, coinWallet: coinWallet, referral: referral)
                )
                
                return .init(signers: signers, instructions: instructions + cleanupInstructions)
            }
    }
    
    private func swapTransitive(
        fromMint: PublicKey,
        toMint: PublicKey,
        fromWallet: PublicKey,
        toWallet: PublicKey,
        pcWallet: PublicKey,
        amount: Lamports,
        minExpectedSwapAmount: Lamports,
        referral: PublicKey?,
        currentSigners: [Account],
        currentInstructions: [TransactionInstruction],
        cleanupInstructions: [TransactionInstruction]
    ) -> Single<SignersAndInstructions> {
        // Try usdc market first, then usdt
        Single.zip(
            client.getMarketAddress(usdxMint: .usdcMint, baseMint: fromMint),
            client.getMarketAddress(usdxMint: .usdcMint, baseMint: toMint)
        )
            .catch {_ in
                
                return Single.zip(
                    self.client.getMarketAddress(usdxMint: .usdtMint, baseMint: fromMint),
                    self.client.getMarketAddress(usdxMint: .usdtMint, baseMint: toMint)
                )
            }
            .flatMap {fromMarketAddress, toMarketAddress -> Single<(Market, Market, UInt64)> in
                
                return Single.zip(
                    Market.load(client: self.client, address: fromMarketAddress, programId: .dexPID),
                    Market.load(client: self.client, address: toMarketAddress, programId: .dexPID),
                    OpenOrders.getMinimumBalanceForRentExemption(client: self.client, programId: .dexPID)
                )
            }
            .flatMap {fromMarket, toMarket, minRentExemption -> Single<(fromMarket: Market, toMarket: Market, fromVaultSigner: PublicKey, toVaultSigner: PublicKey, fromOpenOrder: GetOpenOrderResult, toOpenOrder: GetOpenOrderResult)> in
                
                
                guard let owner = self.accountProvider.getNativeWalletAddress()
                else {throw SerumSwapError.unauthorized}
                
                return Single.zip(
                    .just(fromMarket),
                    .just(toMarket),
                    Self.getVaultOwnerAndNonce(
                        marketPublicKey: fromMarket.publicKey,
                        dexProgramId: .dexPID
                    ).map {$0.vaultOwner},
                    Self.getVaultOwnerAndNonce(
                        marketPublicKey: toMarket.publicKey,
                        dexProgramId: .dexPID
                    ).map {$0.vaultOwner},
                    OpenOrders.findAnOpenOrderOrCreateOne(
                        client: self.client,
                        marketAddress: fromMarket.address,
                        ownerAddress: owner,
                        programId: .dexPID,
                        minRentExemption: minRentExemption
                    ),
                    OpenOrders.findAnOpenOrderOrCreateOne(
                        client: self.client,
                        marketAddress: toMarket.address,
                        ownerAddress: owner,
                        programId: .dexPID,
                        minRentExemption: minRentExemption
                    )
                )
                    .map {(fromMarket: $0, toMarket: $1, fromVaultSigner: $2, toVaultSigner: $3, fromOpenOrder: $4, toOpenOrder: $5)}
            }
            .map {params -> SignersAndInstructions in
                
                
                guard let fromOpenOrder = params.fromOpenOrder.existingOpenOrder ?? params.fromOpenOrder.newOpenOrder?.signers.first?.publicKey,
                      
                      let toOpenOrder = params.toOpenOrder.existingOpenOrder ?? params.toOpenOrder.newOpenOrder?.signers.first?.publicKey
                else {throw SerumSwapError("Could not find or create new order")}
                
                var signers = currentSigners
                var instructions = currentInstructions
                var cleanupInstructions = cleanupInstructions
                
                if let newOrder = params.fromOpenOrder.newOpenOrder {
                    signers += newOrder.signers
                    instructions += newOrder.instructions
                    
                    // TODO: - uncomment once the DEX supports closing open orders accounts.
//                    cleanupInstructions.append(
//                        self.closeAccountInstruction(
//                            order: openOrder,
//                            marketAddress: market.address
//                        )
//                    )
                }
                
                if let newOrder = params.toOpenOrder.newOpenOrder {
                    signers += newOrder.signers
                    instructions += newOrder.instructions
                    
                    // TODO: - uncomment once the DEX supports closing open orders accounts.
//                    cleanupInstructions.append(
//                        self.closeAccountInstruction(
//                            order: openOrder,
//                            marketAddress: market.address
//                        )
//                    )
                }
                
                // add swap instruction
                instructions.append(
                    self.transitiveSwapInstruction(fromMarketClient: params.fromMarket, toMarketClient: params.toMarket, fromVaultSigner: params.fromVaultSigner, toVaultSigner: params.toVaultSigner, fromOpenOrder: fromOpenOrder, toOpenOrder: toOpenOrder, fromWallet: fromWallet, toWallet: toWallet, pcWallet: pcWallet, referral: referral)
                )
                
                return .init(signers: signers, instructions: instructions + cleanupInstructions)
            }
            
    }
    
    // MARK: - Helpers
    private func findMarketsAndOpenOrders(
        usdxMint: PublicKey,
        fromMint: PublicKey,
        toMint: PublicKey
    ) -> Single<(marketFrom: PublicKey, marketTo: PublicKey, marketFromOrders: [OpenOrders], marketToOrders: [OpenOrders])>
    {
        Single.zip(
            client.getMarketAddress(usdxMint: usdxMint, baseMint: fromMint),
            client.getMarketAddress(usdxMint: usdxMint, baseMint: toMint)
        )
        .flatMap {marketFrom, marketTo -> Single<(PublicKey, PublicKey, [OpenOrders], [OpenOrders])> in
            
            
            guard let owner = self.accountProvider.getNativeWalletAddress()
            else {throw SerumSwapError.unauthorized}
            
            return Single.zip(
                .just(marketFrom),
                .just(marketTo),
                OpenOrders.findForMarketAndOwner(
                    client: self.client,
                    marketAddress: marketFrom,
                    ownerAddress: owner,
                    programId: .dexPID
                ),
                OpenOrders.findForMarketAndOwner(
                    client: self.client,
                    marketAddress: marketTo,
                    ownerAddress: owner,
                    programId: .dexPID
                )
            )
        }
        .map {(marketFrom: $0, marketTo: $1, marketFromOrders: $2, marketToOrders: $3)}
    }
    
    // https://github.com/project-serum/serum-dex/blob/e7214bbc455d37a483427a5c37c194246d457502/dex/src/instruction.rs
    private func closeAccountInstruction(
        order: PublicKey,
        marketAddress: PublicKey,
        owner: PublicKey
    ) -> TransactionInstruction {
        TransactionInstruction(
            keys: [
                .init(publicKey: order, isSigner: false, isWritable: true),
                .init(publicKey: owner, isSigner: true, isWritable: false),
                .init(publicKey: marketAddress, isSigner: false, isWritable: false),
                .init(publicKey: .sysvarRent, isSigner: false, isWritable: false),
//                .init(publicKey: <#T##SolanaSDK.PublicKey#>, isSigner: <#T##Bool#>, isWritable: <#T##Bool#>) // 4. `[signer]` open orders market authority (optional).
            ],
            programId: .dexPID,
            data: [UInt8(14)]
        )
    }
    
    // https://github.com/project-serum/serum-dex/blob/e7214bbc455d37a483427a5c37c194246d457502/dex/src/instruction.rs
    private func initAccountInstruction(
        order: PublicKey,
        marketAddress: PublicKey
    ) -> TransactionInstruction {
        // TODO: - initAccount instruction
//        this.program.instruction.initAccount({
//            accounts: {
//                openOrders: openOrders.publicKey,
//                authority: this.program.provider.wallet.publicKey,
//                market: marketAddress,
//                dexProgram: DEX_PID,
//                rent: SYSVAR_RENT_PUBKEY,
//            },
//        }),
        fatalError()
    }
    
    private func directSwapInstruction(
        authority: PublicKey,
        side: Side,
        amount: Lamports,
        minExpectedSwapAmount: Lamports,
        market: Market,
        vaultSigner: PublicKey,
        openOrders: PublicKey,
        pcWallet: PublicKey,
        coinWallet: PublicKey,
        referral: PublicKey?
    ) -> TransactionInstruction {
        TransactionInstruction(
            keys: [
                .init(publicKey: market.address, isSigner: false, isWritable: true),
                .init(publicKey: openOrders, isSigner: false, isWritable: true),
                .init(publicKey: market.decoded.requestQueue, isSigner: false, isWritable: true),
                .init(publicKey: market.decoded.eventQueue, isSigner: false, isWritable: true),
                .init(publicKey: market.bidsAddress, isSigner: false, isWritable: true),
                .init(publicKey: market.asksAddress, isSigner: false, isWritable: true),
                .init(publicKey: side == .bid ? pcWallet: coinWallet, isSigner: false, isWritable: true),
                .init(publicKey: market.decoded.baseVault, isSigner: false, isWritable: true),
                .init(publicKey: vaultSigner, isSigner: false, isWritable: false),
                .init(publicKey: coinWallet, isSigner: false, isWritable: true),
                .init(publicKey: authority, isSigner: true, isWritable: false),
                .init(publicKey: pcWallet, isSigner: false, isWritable: true),
                .init(publicKey: .dexPID, isSigner: false, isWritable: false),
                .init(publicKey: .tokenProgramId, isSigner: false, isWritable: false),
                .init(publicKey: .sysvarRent, isSigner: false, isWritable: false)
            ],
            programId: .serumSwapPID,
            data: [
                side.byte,
                amount,
                minExpectedSwapAmount
            ]
        )
    }
    
    private func transitiveSwapInstruction(
        fromMarketClient: Market,
        toMarketClient: Market,
        fromVaultSigner: PublicKey,
        toVaultSigner: PublicKey,
        fromOpenOrder: PublicKey,
        toOpenOrder: PublicKey,
        fromWallet: PublicKey,
        toWallet: PublicKey,
        pcWallet: PublicKey,
        referral: PublicKey?
    ) -> TransactionInstruction {
//        this.program.instruction.swap(side, amount, minExpectedSwapAmount, {
//            accounts: {
//              market: {
//                market: marketClient.address,
//                // @ts-ignore
//                requestQueue: marketClient._decoded.requestQueue,
//                // @ts-ignore
//                eventQueue: marketClient._decoded.eventQueue,
//                bids: marketClient.bidsAddress,
//                asks: marketClient.asksAddress,
//                // @ts-ignore
//                coinVault: marketClient._decoded.baseVault,
//                // @ts-ignore
//                pcVault: marketClient._decoded.quoteVault,
//                vaultSigner,
//                openOrders,
//                orderPayerTokenAccount: side.bid ? pcWallet : coinWallet,
//                coinWallet: coinWallet,
//              },
//              pcWallet,
//              authority: this.program.provider.wallet.publicKey,
//              dexProgram: DEX_PID,
//              tokenProgram: TOKEN_PROGRAM_ID,
//              rent: SYSVAR_RENT_PUBKEY,
//            },
//            remainingAccounts: referral && [referral],
//        }),
        fatalError()
    }
}
