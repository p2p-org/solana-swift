//
//  SerumSwap.swift
//  SolanaSwift
//
//  Created by Chung Tran on 09/08/2021.
//

import Foundation
import RxSwift

// MARK: - Constants
private var usdcMint: SolanaSDK.PublicKey { try! SolanaSDK.PublicKey(string: "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v") }
private var usdtMint: SolanaSDK.PublicKey { try! SolanaSDK.PublicKey(string: "Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB") }
private var dexPID: SolanaSDK.PublicKey { try! SolanaSDK.PublicKey(string: "9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin") }

public class SerumSwap {
    public typealias Account = SolanaSDK.Account
    public typealias TransactionInstruction = SolanaSDK.TransactionInstruction
    public typealias PublicKey = SolanaSDK.PublicKey
    public typealias TransactionID = SolanaSDK.TransactionID
    public typealias AccountInfo = SolanaSDK.AccountInfo
    public typealias SystemProgram = SolanaSDK.SystemProgram
    public typealias TokenProgram = SolanaSDK.TokenProgram
    public typealias Lamports = SolanaSDK.Lamports
    public typealias Decimals = SolanaSDK.Decimals
    public typealias EncodableWrapper = SolanaSDK.EncodableWrapper
    public typealias BufferInfo = SolanaSDK.BufferInfo
    
    // MARK: - Nested type
    public struct SignersAndInstructions {
        let signers: [Account]
        let instructions: [TransactionInstruction]
    }
    
    // Side rust enum used for the program's RPC API.
    public enum Size {
        case bid, ask
        var params: [String: [String: String]] {
            switch self {
            case .bid:
                return ["bid": [:]]
            case .ask:
                return ["ask": [:]]
            }
        }
    }
    
    // MARK: - Properties
    let client: SerumSwapAPIClient
    let accountProvider: SerumSwapAccountProvider
    
    // MARK: - Initializers
    init(client: SerumSwapAPIClient, accountProvider: SerumSwapAccountProvider) {
        self.client = client
        self.accountProvider = accountProvider
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
        if fromMint == usdcMint || fromMint == usdtMint {
            return createAndInitAccountForDirectSwapOnUSDX(
                fromMint: fromMint,
                toMint: toMint
            )
        }
        else if toMint == usdcMint || toMint == usdtMint {
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
                usdxMint: usdcMint,
                fromMint: fromMint,
                toMint: toMint
            )
            .catch {[weak self] _ in
                guard let self = self else {return .error(SerumSwapError.unknown)}
                // Retry with building transitive with usdtMint
                return self.buildTransitiveForInitAccounts(
                    usdxMint: usdtMint,
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
            fromMint: fromMint,
            toMint: toMint
        )
        .flatMap {[weak self] marketAddress in
            guard let self = self else {throw SerumSwapError.unknown}
            return self.createAndInitAccount(marketAddress: marketAddress)
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
            .flatMap { [weak self] marketFrom, marketTo, ooAccsFrom, ooAccsTo  in
                guard let self = self else {throw SerumSwapError.unknown}
                
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
        
        let ownerAddress = accountProvider.getNativeWalletAddress()
        
        // form instruction
        return OpenOrders.makeCreateAccountInstruction(
            client: client,
            marketAddress: marketAddress,
            ownerAddress: ownerAddress,
            newAccountAddress: newAccount.publicKey,
            programId: dexPID
        )
        .map {[weak self] createAccountInstruction in
            guard let self = self else {throw SerumSwapError.unknown}
            var instructions = [createAccountInstruction]
            instructions.append(self.initAccountInstruction())
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
        
        if fromMint == usdcMint || fromMint == usdtMint {
            instructionRequest = closeAccountForDirectSwapOnUSDX(
                fromMint: fromMint,
                toMint: toMint
            )
        }
        else if toMint == usdcMint || toMint == usdtMint {
            instructionRequest = closeAccountForDirectSwapOnUSDX(
                fromMint: toMint,
                toMint: fromMint
            )
        }
        // Transitive swap across USD(x).
        else {
            instructionRequest = buildTransitiveForCloseAccount(
                usdxMint: usdcMint,
                fromMint: fromMint,
                toMint: toMint
            )
            .catch {[weak self] _ in
                guard let self = self else {return .error(SerumSwapError.unknown)}
                // Retry with building transitive with usdtMint
                return self.buildTransitiveForCloseAccount(
                    usdxMint: usdtMint,
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
        .map { [weak self] marketFrom, marketTo, ooAccsFrom, ooAccsTo  in
            guard let self = self else {throw SerumSwapError.unknown}
            if ooAccsFrom.first == nil && ooAccsTo.first == nil {
                throw SerumSwapError("No open orders accounts left to close")
            }
            if let order = ooAccsFrom.first {
                return self.closeAccountInstruction(order: order)
            }
            
            if let order = ooAccsTo.first {
                return self.closeAccountInstruction(order: order)
            }
            
            throw SerumSwapError.unknown
        }
    }
    
    private func closeAccountForDirectSwapOnUSDX(
        fromMint: PublicKey,
        toMint: PublicKey
    ) -> Single<TransactionInstruction>
    {
        
        return client.getMarketAddress(fromMint: fromMint, toMint: toMint)
            .flatMap {[weak self] marketAddress -> Single<([OpenOrders], PublicKey)> in
                guard let self = self else {throw SerumSwapError.unknown}
                return Single.zip(
                    OpenOrders.findForMarketAndOwner(
                        client: self.client,
                        marketAddress: marketAddress,
                        ownerAddress: self.accountProvider.getNativeWalletAddress(),
                        programId: dexPID
                    ),
                    .just(marketAddress)
                )
            }
            .map {[weak self] openOrders, marketAddress in
                guard let self = self else {throw SerumSwapError.unknown}
                guard let order = openOrders.first else {throw SerumSwapError("Open orders account doesn't exist")}
                return self.closeAccountInstruction(order: order)
            }
    }
    
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
    public func swap(
        fromMint: PublicKey,
        toMint: PublicKey,
        amount: Lamports,
        minExpectedSwapAmount: Lamports?,
        referral: PublicKey?,
        quoteWallet: PublicKey?,
        fromWallet: PublicKey,
        toWallet: PublicKey?,
        feePayer: PublicKey?,
        configs: SolanaSDK.RequestConfiguration? = nil
    ) -> Single<SignersAndInstructions> {
        
        prepareForSwap(
            fromMint: fromMint,
            toMint: toMint,
            amount: amount,
            minExpectedSwapAmount: minExpectedSwapAmount,
            referral: referral,
            quoteWallet: quoteWallet,
            fromWallet: fromWallet,
            toWallet: toWallet,
            feePayer: feePayer,
            configs: configs
        )
    }
    
    /**
     * Returns an estimate for the number of *to*, i.e., output, tokens one would
     * get for the given swap parameters. This is useful to inform the user
     * approximately what will happen if the user executes the swap trade. UIs
     * should use this in conjunction with some bound (e.g. 5%), to prevent users
     * from making unexpected trades.
     */
    public func estimate(
        fromMint: PublicKey,
        toMint: PublicKey,
        amount: Lamports,
        minExpectedSwapAmount: Lamports?,
        referral: PublicKey?,
        quoteWallet: PublicKey?,
        fromWallet: PublicKey,
        toWallet: PublicKey?,
        feePayer: PublicKey?,
        configs: SolanaSDK.RequestConfiguration? = nil
    ) -> Single<Lamports> {
        // Build the transaction.
//        prepareForSwap(
//            fromMint: fromMint,
//            toMint: toMint,
//            amount: amount,
//            minExpectedSwapAmount: minExpectedSwapAmount,
//            referral: referral,
//            quoteWallet: quoteWallet,
//            fromWallet: fromWallet,
//            toWallet: toWallet,
//            configs: configs
//        )
//        .flatMap {[weak self] signersAndInstructions in
//            
//        }
        fatalError()
    }
    
    private func prepareForSwap(
        fromMint: PublicKey,
        toMint: PublicKey,
        amount: Lamports,
        minExpectedSwapAmount: Lamports?,
        referral: PublicKey?,
        quoteWallet: PublicKey?,
        fromWallet: PublicKey,
        toWallet: PublicKey?,
        feePayer: PublicKey?,
        configs: SolanaSDK.RequestConfiguration? = nil
    ) -> Single<SignersAndInstructions> {
        // min expected swap amount
        let requestMinExpectedSwapAmount: Single<Lamports>
        if let minExpectedSwapAmount = minExpectedSwapAmount {
            requestMinExpectedSwapAmount = .just(minExpectedSwapAmount)
        } else {
            requestMinExpectedSwapAmount = estimate(fromMint: fromMint, toMint: toMint, amount: amount, minExpectedSwapAmount: minExpectedSwapAmount, referral: referral, quoteWallet: quoteWallet, fromWallet: fromWallet, toWallet: toWallet, feePayer: feePayer)
                .map {estimated in
                    // Defaults to 0.5% error off the estimate, if not provided.
                    SerumSwap.Lamports(BInt(estimated) * BInt(995) / BInt(1000))
                }
        }
        
        // Prepare source account, create and init new account if fromWallet is native.
        let requestSourceAccount = client.prepareSourceAccountAndInstructions(
            myNativeWallet: accountProvider.getNativeWalletAddress(),
            source: fromWallet,
            sourceMint: fromMint,
            amount: amount,
            feePayer: feePayer ?? accountProvider.getNativeWalletAddress()
        )
        
        // Prepare destination account, create associated token if toWallet is native.
        let requestDestinationAccount = client.prepareDestinationAccountAndInstructions(
            myAccount: accountProvider.getNativeWalletAddress(),
            destination: toWallet,
            destinationMint: toMint,
            feePayer: feePayer ?? accountProvider.getNativeWalletAddress()
        )
        
        // Swap
        return Single.zip(
            requestMinExpectedSwapAmount,
            requestSourceAccount,
            requestDestinationAccount
        )
        .flatMap {[weak self] minExpectedSwapAmount, sourceAccountInstructions, destinationAccountInstructions in
            guard let self = self else { throw SerumSwapError.unknown }
            
            let instructions = sourceAccountInstructions.instructions + destinationAccountInstructions.instructions
            let cleanupInstructions = sourceAccountInstructions.cleanupInstructions + destinationAccountInstructions.cleanupInstructions
            
            // If swapping to/from a USD(x) token, then swap directly on the market.
            if fromMint == usdcMint || fromMint == usdtMint {
                return self.swapDirect(
                    coinWallet: destinationAccountInstructions.account,
                    pcWallet: sourceAccountInstructions.account,
                    baseMint: toMint,
                    quoteMint: fromMint,
                    size: .bid,
                    amount: amount,
                    minExpectedSwapAmount: minExpectedSwapAmount,
                    referral: referral,
                    currentInstructions: instructions,
                    cleanupInstructions: cleanupInstructions
                )
            }
            else if toMint == usdcMint || toMint == usdtMint {
                return self.swapDirect(
                    coinWallet: sourceAccountInstructions.account,
                    pcWallet: destinationAccountInstructions.account,
                    baseMint: fromMint,
                    quoteMint: toMint,
                    size: .ask,
                    amount: amount,
                    minExpectedSwapAmount: minExpectedSwapAmount,
                    referral: referral,
                    currentInstructions: instructions,
                    cleanupInstructions: cleanupInstructions
                )
            }
            
            // Neither wallet is a USD stable coin. So perform a transitive swap.
            let requestQuoteWallet: Single<PublicKey>
            if let quoteWallet = quoteWallet {
                requestQuoteWallet = .just(quoteWallet)
            } else {
                requestQuoteWallet = self.client.usdcPathExists(
                    fromMint: fromMint,
                    toMint: toMint
                )
                .map {[weak self] usdcPathExists in
                    guard let self = self else { throw SerumSwapError.unknown }
                    if usdcPathExists {
                        return try PublicKey.associatedTokenAddress(
                            walletAddress: self.accountProvider.getNativeWalletAddress(),
                            tokenMintAddress: usdcMint
                        )
                    } else {
                        return try PublicKey.associatedTokenAddress(
                            walletAddress: self.accountProvider.getNativeWalletAddress(),
                            tokenMintAddress: usdtMint
                        )
                    }
                }
            }
            
            return requestQuoteWallet
                .flatMap {[weak self] quoteWallet in
                    guard let self = self else { throw SerumSwapError.unknown }
                    return self.swapTransitive(
                        fromMint: fromMint,
                        toMint: toMint,
                        fromWallet: sourceAccountInstructions.account,
                        toWallet: destinationAccountInstructions.account,
                        pcWallet: quoteWallet,
                        amount: amount,
                        minExpectedSwapAmount: minExpectedSwapAmount,
                        referral: referral,
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
        size: Size,
        amount: Lamports,
        minExpectedSwapAmount: Lamports,
        referral: PublicKey?,
        currentInstructions: [TransactionInstruction],
        cleanupInstructions: [TransactionInstruction]
    ) -> Single<SignersAndInstructions> {
        
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
        currentInstructions: [TransactionInstruction],
        cleanupInstructions: [TransactionInstruction]
    ) -> Single<SignersAndInstructions> {
        
    }
    
    // MARK: - Helpers
    private func findMarketsAndOpenOrders(
        usdxMint: PublicKey,
        fromMint: PublicKey,
        toMint: PublicKey
    ) -> Single<(marketFrom: PublicKey, marketTo: PublicKey, marketFromOrders: [OpenOrders], marketToOrders: [OpenOrders])>
    {
        Single.zip(
            client.getMarketAddress(fromMint: usdxMint, toMint: fromMint),
            client.getMarketAddress(fromMint: usdxMint, toMint: toMint)
        )
        .flatMap {[weak self] marketFrom, marketTo -> Single<(PublicKey, PublicKey, [OpenOrders], [OpenOrders])> in
            guard let self = self else {throw SerumSwapError.unknown}
            return Single.zip(
                .just(marketFrom),
                .just(marketTo),
                OpenOrders.findForMarketAndOwner(
                    client: self.client,
                    marketAddress: marketFrom,
                    ownerAddress: self.accountProvider.getNativeWalletAddress(),
                    programId: dexPID
                ),
                OpenOrders.findForMarketAndOwner(
                    client: self.client,
                    marketAddress: marketTo,
                    ownerAddress: self.accountProvider.getNativeWalletAddress(),
                    programId: dexPID
                )
            )
        }
        .map {(marketFrom: $0, marketTo: $1, marketFromOrders: $2, marketToOrders: $3)}
    }
    
    private func closeAccountInstruction(
        order: OpenOrders
    ) -> TransactionInstruction {
        // TODO: - closeAccount instruction
//                this.program.instruction.closeAccount({
//                  accounts: {
//                    openOrders: ooAccsTo[0].publicKey,
//                    authority: this.program.provider.wallet.publicKey,
//                    destination: this.program.provider.wallet.publicKey,
//                    market: marketTo,
//                    dexProgram: DEX_PID,
//                  },
//                }),
        fatalError()
    }
    
    private func initAccountInstruction() -> TransactionInstruction {
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
}
