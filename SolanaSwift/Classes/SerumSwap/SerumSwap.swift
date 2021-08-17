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
private let CLOSE_ENABLED = false

// Initialize open orders feature flag.
//
// TODO: enable once the DEX supports initializing open orders accounts.
private let OPEN_ENABLED = false

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
    
    /// Executes a swap against the Serum DEX.
    /// - Parameter params: SwapParams
    /// - Returns: Signers and instructions for creating multiple transactions
    public func swap(_ params: SwapParams) -> Single<[SignersAndInstructions]> {
        swapTxs(params)
            .map {tx in
                if let additionalTxs = params.additionalTransactions {
                    return [tx] + additionalTxs
                }
                return [tx]
            }
    }
    
    private func swapTxs(_ params: SwapParams) -> Single<SignersAndInstructions> {
        // check if fromMint and toMint are equal
        guard params.fromMint != params.toMint else {return .error(SerumSwapError("Can not swap \(params.fromMint) to itself"))}
        
        // If swapping to/from a USD(x) token, then swap directly on the market.
        if params.fromMint.isUsdx {
            var coinWallet = params.toWallet
            var pcWallet = params.fromWallet
            var baseMint = params.toMint
            var quoteMint: PublicKey?
            var side = Side.bid
            
            // Special case USDT/USDC market since the coin is always USDT and
            // the pc is always USDC.
            if params.toMint == .usdcMint {
                coinWallet = params.fromWallet
                pcWallet = params.toWallet
                baseMint = params.fromMint
                quoteMint = params.toMint
                side = .ask
            }
            // Special case USDC/USDT market since the coin is always USDC and
            // the pc is always USDT.
            else if params.toMint == .usdtMint {
                coinWallet = params.toWallet
                pcWallet = params.fromWallet
                baseMint = params.toMint
                quoteMint = params.quoteMint
                side = .bid
            }
            
            return swapDirectTxs(
                coinWallet: coinWallet,
                pcWallet: pcWallet,
                baseMint: baseMint,
                quoteMint: quoteMint ?? params.fromMint,
                side: side,
                amount: params.amount,
                minExchangeRate: params.minExchangeRate,
                referral: params.referral,
                close: params.close,
                fromMarket: params.fromMarket,
                fromOpenOrders: params.fromOpenOrders,
                feePayer: params.feePayer
            )
        }
        else if params.toMint.isUsdx {
            return swapDirectTxs(
                coinWallet: params.fromWallet,
                pcWallet: params.toWallet,
                baseMint: params.fromMint,
                quoteMint: params.toMint,
                side: .ask,
                amount: params.amount,
                minExchangeRate: params.minExchangeRate,
                referral: params.referral,
                close: params.close,
                fromMarket: params.fromMarket,
                fromOpenOrders: params.fromOpenOrders,
                feePayer: params.feePayer
            )
        }
        
        // Direct swap market explicitly given.
        if params.toMarket == nil {
            return swapDirectTxs(
                coinWallet: params.fromWallet,
                pcWallet: params.toWallet,
                baseMint: params.fromMint,
                quoteMint: params.toMint,
                side: params.fromMint == params.fromMarket.baseMintAddress ? .ask: .bid,
                amount: params.amount,
                minExchangeRate: params.minExchangeRate,
                referral: params.referral,
                close: params.close,
                fromMarket: params.fromMarket,
                fromOpenOrders: params.fromOpenOrders,
                feePayer: params.feePayer
            )
        }
        
        // Neither wallet is a USD stable coin. So perform a transitive swap.
        guard let quoteMint = params.quoteMint else {
            return .error(SerumSwapError("quoteMint must be provided for a transitive swap"))
        }
        guard let toMarket = params.toMarket else {
            return .error(SerumSwapError("toMarket must be provided for transitive swaps"))
        }
        
        return swapTransitiveTxs(
            fromMint: params.fromMint,
            toMint: params.toMint,
            pcMint: quoteMint,
            fromWallet: params.fromWallet,
            toWallet: params.toWallet,
            pcWallet: params.quoteWallet,
            amount: params.amount,
            minExchangeRate: params.minExchangeRate,
            referral: params.referral,
            close: params.close,
            fromMarket: params.fromMarket,
            toMarket: toMarket,
            fromOpenOrders: params.fromOpenOrders,
            toOpenOrders: params.toOpenOrders,
            feePayer: params.feePayer
        )
    }
    
    private func swapDirectTxs(
        coinWallet: PublicKey?,
        pcWallet: PublicKey?,
        baseMint: PublicKey,
        quoteMint: PublicKey,
        side: Side,
        amount: Lamports,
        minExchangeRate: ExchangeRate,
        referral: PublicKey?,
        close: Bool?,
        fromMarket: Market,
        fromOpenOrders: PublicKey?,
        feePayer: PublicKey?
    ) -> Single<SignersAndInstructions> {
        guard let owner = accountProvider.getNativeWalletAddress()
        else {return .error(SerumSwapError.unauthorized)}
        
        // get vaultSigner
        let requestVaultSigner = Self.getVaultOwnerAndNonce(
            marketPublicKey: fromMarket.address
        )
            .map {$0.vaultOwner}
        
        // prepare source account, create associated token address if source wallet is native
        let requestSourceAccount = client.prepareValidAccountAndInstructions(
            myAccount: owner,
            address: coinWallet ?? owner,
            mint: baseMint,
            feePayer: feePayer ?? owner,
            closeAfterward: baseMint == .wrappedSOLMint
        )

        // prepare destination account, create associated token if destination wallet is native or nil.
        let requestDestinationAccount = client.prepareValidAccountAndInstructions(
            myAccount: owner,
            address: pcWallet,
            mint: quoteMint,
            feePayer: feePayer ?? owner,
            closeAfterward: quoteMint == .wrappedSOLMint
        )
        
        // get open order
        let requestOpenOrders = prepareOpenOrder(
            orders: fromOpenOrders,
            market: fromMarket
        )
        
        return Single.zip(
            requestVaultSigner,
            requestSourceAccount,
            requestDestinationAccount,
            requestOpenOrders
        )
        .map { vaultSigner, sourceAccountInstructions, destinationAccountInstructions, openOrdersAccountInstructions in
            var signers = [Account]()
            var instructions = [TransactionInstruction]()
            signers += sourceAccountInstructions.signers
            signers += destinationAccountInstructions.signers
            signers += openOrdersAccountInstructions.signers
            
            instructions += sourceAccountInstructions.instructions
            instructions += destinationAccountInstructions.instructions
            instructions += openOrdersAccountInstructions.instructions
            
            instructions.append(
                directSwapInstruction(
                    authority: owner,
                    side: side,
                    amount: amount,
                    minExchangeRate: minExchangeRate,
                    market: fromMarket,
                    vaultSigner: vaultSigner,
                    openOrders: openOrdersAccountInstructions.account,
                    pcWallet: destinationAccountInstructions.account,
                    coinWallet: sourceAccountInstructions.account,
                    referral: referral
                )
            )
            
            instructions += sourceAccountInstructions.cleanupInstructions
            instructions += destinationAccountInstructions.cleanupInstructions
            if CLOSE_ENABLED && close == true {
                instructions += openOrdersAccountInstructions.cleanupInstructions
            }
            
            return .init(signers: signers, instructions: instructions)
        }
    }
    
    private func swapTransitiveTxs(
        fromMint: PublicKey,
        toMint: PublicKey,
        pcMint: PublicKey,
        fromWallet: PublicKey?,
        toWallet: PublicKey?,
        pcWallet: PublicKey?,
        amount: Lamports,
        minExchangeRate: ExchangeRate,
        referral: PublicKey?,
        close: Bool?,
        fromMarket: Market,
        toMarket: Market,
        fromOpenOrders: PublicKey?,
        toOpenOrders: PublicKey?,
        feePayer: PublicKey?
    ) -> Single<SignersAndInstructions> {
        guard let owner = accountProvider.getNativeWalletAddress()
        else {return .error(SerumSwapError.unauthorized)}
        
        // Calculate the vault signers for each market.
        let requestFromVaultSigner = Self.getVaultOwnerAndNonce(marketPublicKey: fromMarket.address)
            .map {$0.vaultOwner}
        let requestToVaultSigner = Self.getVaultOwnerAndNonce(marketPublicKey: toMarket.address)
            .map {$0.vaultOwner}
        
        // Prepare source, destination and pc wallets
        let requestSourceAccountInstructions = client.prepareValidAccountAndInstructions(
            myAccount: owner,
            address: fromWallet,
            mint: fromMint,
            feePayer: feePayer ?? owner,
            closeAfterward: fromMint == .wrappedSOLMint
        )
        let requestDestinationAccountInstructions = client.prepareValidAccountAndInstructions(
            myAccount: owner,
            address: toWallet,
            mint: toMint,
            feePayer: feePayer ?? owner,
            closeAfterward: toMint == .wrappedSOLMint
        )
        let requestPcAccountInstructions = client.prepareValidAccountAndInstructions(
            myAccount: owner,
            address: pcWallet,
            mint: pcMint,
            feePayer: feePayer ?? owner,
            closeAfterward: pcMint == .wrappedSOLMint
        )
        
        // Prepare open orders
        let requestOpenOrders = OpenOrders.getMinimumBalanceForRentExemption(client: client, programId: .dexPID)
            .flatMap {minRentExemption in
                Single.zip(
                    prepareOpenOrder(
                        orders: fromOpenOrders,
                        market: fromMarket,
                        minRentExemption: minRentExemption
                    ),
                    prepareOpenOrder(
                        orders: toOpenOrders,
                        market: toMarket,
                        minRentExemption: minRentExemption
                    )
                )
            }
        
        return Single.zip(
            requestFromVaultSigner,
            requestToVaultSigner,
            requestSourceAccountInstructions,
            requestDestinationAccountInstructions,
            requestPcAccountInstructions,
            requestOpenOrders
        )
        .map { fromVaultSigner, toVaultSigner, sourceAccountInstructions, destinationAccountInstructions, pcAccountInstructions, openOrdersAccountInstructions in
            let fromOpenOrdersAccountInstructions = openOrdersAccountInstructions.0
            let toOpenOrdersAccountInstructions = openOrdersAccountInstructions.1
            
            var signers = [Account]()
            var instructions = [TransactionInstruction]()
            signers += sourceAccountInstructions.signers
            signers += destinationAccountInstructions.signers
            signers += pcAccountInstructions.signers
            signers += fromOpenOrdersAccountInstructions.signers
            signers += toOpenOrdersAccountInstructions.signers
            
            instructions += sourceAccountInstructions.instructions
            instructions += destinationAccountInstructions.instructions
            instructions += pcAccountInstructions.instructions
            instructions += fromOpenOrdersAccountInstructions.instructions
            instructions += toOpenOrdersAccountInstructions.instructions
            
            instructions.append(
                transitiveSwapInstruction(
                    fromMarketClient: fromMarket,
                    toMarketClient: toMarket,
                    fromVaultSigner: fromVaultSigner,
                    toVaultSigner: toVaultSigner,
                    fromOpenOrder: fromOpenOrdersAccountInstructions.account,
                    toOpenOrder: toOpenOrdersAccountInstructions.account,
                    fromWallet: sourceAccountInstructions.account,
                    toWallet: destinationAccountInstructions.account,
                    pcWallet: pcAccountInstructions.account,
                    referral: referral
                )
            )
            
            instructions += sourceAccountInstructions.cleanupInstructions
            instructions += destinationAccountInstructions.cleanupInstructions
            instructions += pcAccountInstructions.cleanupInstructions
            if CLOSE_ENABLED && close == true {
                instructions += fromOpenOrdersAccountInstructions.cleanupInstructions
                instructions += toOpenOrdersAccountInstructions.cleanupInstructions
            }
            
            return .init(signers: signers, instructions: instructions)
        }
    }
    
    private func prepareOpenOrder(
        orders: PublicKey?,
        market: Market,
        minRentExemption: Lamports? = nil
    ) -> Single<AccountInstructions> {
        guard let owner = accountProvider.getNativeWalletAddress()
        else {return .error(SerumSwapError.unauthorized)}
        
        if let order = orders {
            return .just(
                .init(
                    account: order,
                    cleanupInstructions: [
                        OpenOrders.closeAccountInstruction(
                            order: order,
                            marketAddress: market.address,
                            owner: owner
                        )
                    ]
                )
            )
        } else {
            return OpenOrders.makeCreateAccountInstructions(
                client: client,
                marketAddress: market.address,
                ownerAddress: owner,
                programId: .dexPID,
                minRentExemption: minRentExemption
            )
            .map {accountInstructions in
                var accountInstructions = accountInstructions
                if OPEN_ENABLED {
                    accountInstructions.instructions.append(
                        initAccountInstruction(
                            order: accountInstructions.account,
                            marketAddress: market.address
                        )
                    )
                }
                return accountInstructions
            }
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
        minExchangeRate: ExchangeRate,
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
                minExchangeRate.rate // TODO: - Fix later
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
