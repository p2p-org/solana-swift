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

private var _marketsCache = [SerumSwap.PublicKey: SerumSwap.Market]()
private var _orderbooksCache = [SerumSwap.PublicKey: SerumSwap.OrderbookPair]()

public struct SerumSwap {
    // MARK: - Properties
    let client: SerumSwapAPIClient
    let accountProvider: SerumSwapAccountProvider
    let signatureNotificationHandler: SerumSwapSignatureNotificationHandler
    let swapMarkets: SwapMarkets
    public let BASE_TAKER_FEE_BPS = 0.0022
    public var FEE_MULTIPLIER: Double {1 - BASE_TAKER_FEE_BPS}
    
    // MARK: - Initializers
    public init(
        client: SerumSwapAPIClient,
        accountProvider: SerumSwapAccountProvider,
        tokenListContainer: SerumSwapTokenListContainer,
        signatureNotificationHandler: SerumSwapSignatureNotificationHandler
    ) {
        self.client = client
        self.accountProvider = accountProvider
        self.signatureNotificationHandler = signatureNotificationHandler
        self.swapMarkets = SwapMarkets(tokenListContainer: tokenListContainer)
    }
    
    // MARK: - Methods
    /// Load price of current markets
    public func loadFair(
        fromMint: PublicKey,
        toMint: PublicKey,
        markets: [Market]? = nil
    ) -> Single<Double> {
        let loadMarketsRequest: Single<[Market]>
        if let markets = markets {
            loadMarketsRequest = .just(markets)
        } else {
            loadMarketsRequest = loadMarket(fromMint: fromMint, toMint: toMint)
        }
        return loadMarketsRequest
            .flatMap {markets -> Single<[OrderbookPair]> in
                let singles = markets.map {loadOrderbook(market: $0)}
                return Single.zip(singles)
            }
            .map {orderbookPairs -> Decimal in
                guard orderbookPairs.count > 0 else {
                    throw SerumSwapError.couldNotRetrieveExchangeRate
                }
                // direct
                if orderbookPairs.count == 1 {
                    let pair = orderbookPairs[0]
                    guard let bbo = loadBbo(orderbookPair: pair) else {
                        throw SerumSwapError.couldNotRetrieveExchangeRate
                    }
                    let market = pair.asks.market // the same market as bids
                    if market.baseMintAddress == fromMint ||
                        (market.baseMintAddress == .wrappedSOLMint && fromMint == .solMint)
                    {
                        if let bestBids = bbo.bestBids, bestBids != 0 {
                            return 1 / bestBids
                        }
                    } else {
                        if let bestOffer = bbo.bestOffer {
                            return bestOffer
                        }
                    }
                    
                    throw SerumSwapError.couldNotRetrieveExchangeRate
                }
                // transitive
                guard let fromBbo = loadBbo(orderbookPair: orderbookPairs[0]),
                      let toBbo = loadBbo(orderbookPair: orderbookPairs[1]),
                      let bestOffer = toBbo.bestOffer,
                      let bestBids = fromBbo.bestBids,
                      bestBids != 0
                else {
                    throw SerumSwapError.couldNotRetrieveExchangeRate
                }
                return bestOffer / bestBids
            }
            .map {$0.doubleValue}
    }
    
    /// Load price of current markets
    public func loadFair(
        fromMint: String,
        toMint: String,
        markets: [Market]? = nil
    ) -> Single<Double> {
        guard let fromMint = try? PublicKey(string: fromMint),
              let toMint = try? PublicKey(string: toMint)
        else {return .error(SerumSwapError.somePublicKeysArentValid)}
        return loadFair(fromMint: fromMint, toMint: toMint, markets: markets)
    }
    
    /// Calculate minExchangeRate needed for swap
    /// - Parameters:
    ///   - fair: fair which is gotten from loadFair(fromMint:toMint)
    ///   - slippage: user input slippage
    ///   - fromDecimals: from token decimal
    ///   - toDecimal: to token decimal
    ///   - strict: strict
    /// - Returns: ExchangeRate
    public func calculateExchangeRate(
        fair: Double,
        slippage: Double,
        fromDecimals: Decimals,
        toDecimal: Decimals,
        strict: Bool
    ) -> ExchangeRate {
        var number = (pow(Double(10), Double(toDecimal)) * FEE_MULTIPLIER) / fair
        number *= (100-slippage)
        number /= 100
        return .init(
            rate: Lamports(number),
            fromDecimals: fromDecimals,
            quoteDecimals: toDecimal,
            strict: strict
        )
    }
    
    /// Executes a swap against the Serum DEX.
    /// - Returns: Signers and instructions for creating multiple transactions
    public func swap(
        fromWallet: Wallet,
        toWallet: Wallet,
        amount: Double,
        slippage: Double,
        isSimulation: Bool = false
    ) -> Single<TransactionID> {
        guard let owner = accountProvider.getAccount() else {
            return .error(SerumSwapError.unauthorized)
        }
        
        return loadMarket(
            fromMint: fromWallet.token.address,
            toMint: toWallet.token.address
        )
            .flatMap {markets -> Single<([Market], ExchangeRate, [OpenOrders?])> in
                var toDecimal = toWallet.token.decimals
                // For a direct swap, toDecimal should be zero.
                // https://github.com/project-serum/swap/blob/master/programs/swap/src/lib.rs#L696
                if markets.count == 1 {
                    toDecimal = 0
                }
                
                let requestExchangeRate = loadFair(
                    fromMint: fromWallet.token.address,
                    toMint: toWallet.token.address,
                    markets: markets
                )
                    .map {fair in
                        calculateExchangeRate(
                            fair: fair,
                            slippage: slippage,
                            fromDecimals: fromWallet.token.decimals,
                            toDecimal: toDecimal,
                            strict: false
                        )
                    }
                
                let requestOpenOrders = Single.zip(
                    markets.map {
                        OpenOrders.findForMarketAndOwner(
                            client: client,
                            marketAddress: $0.address,
                            ownerAddress: owner.publicKey
                        )
                            .map {$0.first}
                    }
                )
                
                
                return Single.zip(
                    requestExchangeRate,
                    requestOpenOrders
                )
                    .map {(markets, $0, $1)}
            }
            .flatMap {markets, exchangeRate, openOrders -> Single<[SignersAndInstructions]> in
                guard let fromMint = try? PublicKey(string: fromWallet.token.address),
                      let toMint = try? PublicKey(string: toWallet.token.address),
                      let fromWalletPubkey = try? PublicKey(string: fromWallet.pubkey)
                else {
                    return .error(SerumSwapError.somePublicKeysArentValid)
                }
                
                guard let fromMarket = markets.first else {
                    return .error(SerumSwapError.marketIsNotAvailable)
                }
                
                let toWalletPubkey = try? PublicKey(string: toWallet.pubkey)
                let toMarket: Market? = markets[safe: 1]
                
                return swap(
                    .init(
                        fromMint: fromMint,
                        toMint: toMint,
                        amount: amount.toLamport(decimals: fromWallet.token.decimals),
                        minExchangeRate: exchangeRate,
                        referral: nil,
                        fromWallet: fromWalletPubkey,
                        toWallet: toWalletPubkey,
                        quoteWallet: nil,
                        fromMarket: fromMarket,
                        toMarket: toMarket,
                        fromOpenOrders: openOrders[safe: 0]?.map {$0.address},
                        toOpenOrders: openOrders[safe: 1]?.map {$0.address},
                        close: true
                    ),
                    isSimulation: isSimulation
                )
            }
            .flatMap {signersAndInstructions -> Single<String> in
                let instructions = Array(signersAndInstructions.map{ $0.instructions }.joined())
                var signers = Array(signersAndInstructions.map{ $0.signers }.joined())
                
                // TODO: If fee relayer is available, remove account as signer
                signers.insert(owner, at: 0)
                
                // serialize transaction
                return client.serializeTransaction(
                    instructions: instructions,
                    recentBlockhash: nil,
                    signers: signers,
                    feePayer: nil // TODO: modify for fee relayer
                )
                    .flatMap {serializedTransaction in
                        if isSimulation {
                            return client.simulateTransaction(transaction: serializedTransaction)
                                .map {_ in ""}
                        }
                        // TODO: fee relayer
                        return client.sendTransaction(serializedTransaction: serializedTransaction)
                    }
            }
    }
    
    /// Executes a swap against the Serum DEX.
    /// - Parameter params: SwapParams
    /// - Returns: Signers and instructions for creating multiple transactions
    func swap(_ params: SwapParams, isSimulation: Bool) -> Single<[SignersAndInstructions]> {
        swapTxs(params, isSimulation: isSimulation)
            .map {tx in
                if let additionalTxs = params.additionalTransactions {
                    return [tx] + additionalTxs
                }
                return [tx]
            }
    }
    
    private func swapTxs(_ params: SwapParams, isSimulation: Bool) -> Single<SignersAndInstructions> {
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
                quoteMint = params.fromMint
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
                feePayer: params.feePayer,
                fromMintIsUSDx: true
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
                feePayer: params.feePayer,
                fromMintIsUSDx: false
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
                feePayer: params.feePayer,
                fromMintIsUSDx: false
            )
        }
        
        // Neither wallet is a USD stable coin. So perform a transitive swap.
        let quoteMint = params.fromMarket.quoteMintAddress
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
            feePayer: params.feePayer,
            isSimulation: isSimulation
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
        feePayer: PublicKey?,
        fromMintIsUSDx: Bool
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
            address: coinWallet,
            mint: baseMint,
            initAmount: fromMintIsUSDx ? 0: amount,
            feePayer: feePayer ?? owner,
            closeAfterward: baseMint == .wrappedSOLMint
        )

        // prepare destination account, create associated token if destination wallet is native or nil.
        let requestDestinationAccount = client.prepareValidAccountAndInstructions(
            myAccount: owner,
            address: pcWallet,
            mint: quoteMint,
            initAmount: 0,
            feePayer: feePayer ?? owner,
            closeAfterward: quoteMint == .wrappedSOLMint
        )
        
        // get open order
        let requestOpenOrders = prepareOpenOrder(
            orders: fromOpenOrders,
            market: fromMarket,
            closeAfterward: CLOSE_ENABLED && close == true && fromOpenOrders == nil
        )
        
        return Single.zip(
            requestVaultSigner,
            requestSourceAccount,
            requestDestinationAccount,
            requestOpenOrders
        )
        .map { vaultSigner, sourceAccountInstructions, destinationAccountInstructions, openOrdersAccountInstructions in
            var signers = [Account]()
            signers += sourceAccountInstructions.signers
            signers += destinationAccountInstructions.signers
            signers += openOrdersAccountInstructions.signers
            
            var instructions = [TransactionInstruction]()
            instructions += sourceAccountInstructions.instructions
            instructions += destinationAccountInstructions.instructions
            instructions += openOrdersAccountInstructions.instructions
            
            let coinWallet = sourceAccountInstructions.account
            let pcWallet = destinationAccountInstructions.account
            let openOrders = openOrdersAccountInstructions.account
            
            instructions.append(
                Self.directSwapInstruction(
                    authority: owner,
                    side: side,
                    amount: amount,
                    minExchangeRate: minExchangeRate,
                    market: fromMarket,
                    vaultSigner: vaultSigner,
                    openOrders: openOrders,
                    pcWallet: pcWallet,
                    coinWallet: coinWallet,
                    referral: referral
                )
            )
            
            instructions += sourceAccountInstructions.cleanupInstructions
            instructions += destinationAccountInstructions.cleanupInstructions
            instructions += openOrdersAccountInstructions.cleanupInstructions
            
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
        feePayer: PublicKey?,
        isSimulation: Bool
    ) -> Single<SignersAndInstructions> {
        guard let owner = accountProvider.getAccount()
        else {return .error(SerumSwapError.unauthorized)}
        // Request open orders
        let requestOpenOrders: Single<(from: PublicKey, to: PublicKey, cleanupInstructions: [TransactionInstruction])>
        if let fromOpenOrders = fromOpenOrders,
           let toOpenOrders = toOpenOrders
        {
            requestOpenOrders = .just((from: fromOpenOrders, to: toOpenOrders, cleanupInstructions: []))
        } else {
            requestOpenOrders = createFromAndToOpenOrdersForSwapTransitive(
                fromMarket: fromMarket,
                toMarket: toMarket,
                feePayer: feePayer,
                close: close,
                isSimulation: isSimulation
            )
        }
        
        // Calculate the vault signers for each market.
        let requestFromVaultSigner = Self.getVaultOwnerAndNonce(marketPublicKey: fromMarket.address)
            .map {$0.vaultOwner}
        let requestToVaultSigner = Self.getVaultOwnerAndNonce(marketPublicKey: toMarket.address)
            .map {$0.vaultOwner}
        
        // Prepare source, destination and pc wallets
        let requestSourceAccountInstructions = client.prepareValidAccountAndInstructions(
            myAccount: owner.publicKey,
            address: fromWallet,
            mint: fromMint,
            initAmount: amount,
            feePayer: feePayer ?? owner.publicKey,
            closeAfterward: fromMint == .wrappedSOLMint
        )
        let requestDestinationAccountInstructions = client.prepareValidAccountAndInstructions(
            myAccount: owner.publicKey,
            address: toWallet,
            mint: toMint,
            initAmount: 0,
            feePayer: feePayer ?? owner.publicKey,
            closeAfterward: toMint == .wrappedSOLMint
        )
        let requestPcAccountInstructions = client.prepareValidAccountAndInstructions(
            myAccount: owner.publicKey,
            address: pcWallet,
            mint: pcMint,
            initAmount: 0,
            feePayer: feePayer ?? owner.publicKey,
            closeAfterward: pcMint == .wrappedSOLMint
        )
        
        // Prepare open orders
        return requestOpenOrders
            .flatMap { openOrders in
                Single.zip(
                    requestFromVaultSigner,
                    requestToVaultSigner,
                    requestSourceAccountInstructions,
                    requestDestinationAccountInstructions,
                    requestPcAccountInstructions,
                    .just(openOrders)
                )
            }
            .map { fromVaultSigner, toVaultSigner, sourceAccountInstructions, destinationAccountInstructions, pcAccountInstructions, openOrders in
                var signers = [Account]()
                var instructions = [TransactionInstruction]()
                signers += sourceAccountInstructions.signers
                signers += destinationAccountInstructions.signers
                signers += pcAccountInstructions.signers
                
                instructions += sourceAccountInstructions.instructions
                instructions += destinationAccountInstructions.instructions
                instructions += pcAccountInstructions.instructions
                
                instructions.append(
                    Self.transitiveSwapInstruction(
                        authority: owner.publicKey,
                        fromMarket: fromMarket,
                        toMarket: toMarket,
                        fromVaultSigner: fromVaultSigner,
                        toVaultSigner: toVaultSigner,
                        fromOpenOrder: openOrders.from,
                        toOpenOrder: openOrders.to,
                        fromWallet: sourceAccountInstructions.account,
                        toWallet: destinationAccountInstructions.account,
                        amount: amount,
                        minExchangeRate: minExchangeRate,
                        pcWallet: pcAccountInstructions.account,
                        referral: referral
                    )
                )
                
                instructions += sourceAccountInstructions.cleanupInstructions
                instructions += destinationAccountInstructions.cleanupInstructions
                instructions += pcAccountInstructions.cleanupInstructions
                if CLOSE_ENABLED && close == true {
                    instructions += openOrders.cleanupInstructions
                }
                
                return .init(signers: signers, instructions: instructions)
            }
    }
    
    private func prepareOpenOrder(
        orders: PublicKey?,
        market: Market,
        minRentExemption: Lamports? = nil,
        closeAfterward: Bool
    ) -> Single<AccountInstructions> {
        guard let owner = accountProvider.getNativeWalletAddress()
        else {return .error(SerumSwapError.unauthorized)}
        
        if let order = orders {
            var cleanupInstructions = [TransactionInstruction]()
            if closeAfterward {
                cleanupInstructions.append(
                    Self.closeOrderInstruction(
                        order: order,
                        marketAddress: market.address,
                        owner: owner,
                        destination: owner
                    )
                )
            }
            return .just(
                .init(
                    account: order,
                    cleanupInstructions: cleanupInstructions
                )
            )
        } else {
            return OpenOrders.makeCreateAccountInstructions(
                client: client,
                marketAddress: market.address,
                ownerAddress: owner,
                programId: .dexPID,
                minRentExemption: minRentExemption,
                shouldInitAccount: OPEN_ENABLED,
                closeAfterward: closeAfterward
            )
        }
    }
    
    // MARK: - Helpers
    
    /// Returns a list of markets to trade across to swap `fromMint` to `toMint`.
    func route(fromMint: PublicKey, toMint: PublicKey) -> Single<[PublicKey]?> {
        swapMarkets.route(fromMint: fromMint, toMint: toMint)
    }
    
    /// Load market with current mint pair
    func loadMarket(fromMint: PublicKey, toMint: PublicKey) -> Single<[Market]> {
        route(fromMint: fromMint, toMint: toMint)
            .flatMap {route -> Single<[Market]> in
                guard let route = route else {
                    throw SerumSwapError.couldNotRetrieveExchangeRate
                }
                let singles = route.map {loadMarket(address: $0)}
                return Single.zip(singles)
            }
    }
    
    /// Load market with current mint pair
    func loadMarket(fromMint: String, toMint: String) -> Single<[Market]> {
        guard let fromMint = try? PublicKey(string: fromMint),
              let toMint = try? PublicKey(string: toMint)
        else {return .error(SerumSwapError.somePublicKeysArentValid)}
        return loadMarket(fromMint: fromMint, toMint: toMint)
    }
    
    /// Load a market base on its address
    func loadMarket(address: PublicKey) -> Single<Market> {
        if let market = _marketsCache[address] {
            return .just(market)
        }
        
        return Market.load(
            client: client,
            address: address,
            programId: .dexPID
        )
            .do(onSuccess: {market in
                _marketsCache[address] = market
            })
    }
    
    /// Load orderbook for current market
    /// - Parameter market: market instance
    /// - Returns: OrderbookPair
    func loadOrderbook(market: Market) -> Single<OrderbookPair> {
        if let pair = _orderbooksCache[market.address] {
            return .just(pair)
        }
        
        return Single.zip(
            market.loadBids(client: client),
            market.loadAsks(client: client)
        )
            .map {OrderbookPair(bids: $0, asks: $1)}
            .do(onSuccess: {pair in
                _orderbooksCache[market.address] = pair
            })
    }
    
    /// Load fair price for a given market, as defined by the mid
    /// - Parameter orderbookPair: asks and bids
    /// - Returns: best bids price, best asks price and middle
    func loadBbo(orderbookPair: OrderbookPair) -> Bbo? {
        let bestBid = orderbookPair.bids.getList(descending: true).first
        let bestOffer = orderbookPair.asks.getList().first
        
        if bestBid == nil && bestOffer == nil {return nil}
        return .init(
            bestBids: bestBid == nil ? nil: bestBid!.price,
            bestOffer: bestOffer == nil ? nil: bestOffer!.price
        )
    }
    
    /// Create from and to open orders and wait for comfirmation before transitive swaping
    func createFromAndToOpenOrdersForSwapTransitive(
        fromMarket: Market,
        toMarket: Market,
        feePayer: PublicKey?,
        close: Bool?,
        isSimulation: Bool
    ) -> Single<(from: PublicKey, to: PublicKey, cleanupInstructions: [TransactionInstruction])> {
        OpenOrders.getMinimumBalanceForRentExemption(client: client, programId: .dexPID)
            .flatMap {minRentExemption in
                Single.zip(
                    prepareOpenOrder(
                        orders: nil,
                        market: fromMarket,
                        minRentExemption: minRentExemption,
                        closeAfterward: CLOSE_ENABLED && close == true
                    ),
                    prepareOpenOrder(
                        orders: nil,
                        market: toMarket,
                        minRentExemption: minRentExemption,
                        closeAfterward: CLOSE_ENABLED && close == true
                    )
                )
            }
            .flatMap {from, to in
                var signers = [Account]()
                var instructions = [TransactionInstruction]()
                
                signers += from.signers
                signers += to.signers
                
                instructions += from.instructions
                instructions += to.instructions
                
                if feePayer == nil, let owner = accountProvider.getAccount()
                {
                    signers.insert(owner, at: 1)
                }
                
                // serialize transaction
                return client.serializeTransaction(
                    instructions: instructions,
                    recentBlockhash: nil,
                    signers: signers,
                    feePayer: feePayer // TODO: modify for fee relayer
                )
                    .flatMap {serializedTransaction -> Single<TransactionID> in
                        if isSimulation {
                            return client.simulateTransaction(transaction: serializedTransaction)
                                .map {_ in ""}
                        }
                        // TODO: fee relayer
                        return client.sendTransaction(serializedTransaction: serializedTransaction)
                    }
                    .flatMapCompletable {signature -> Completable in
                        if isSimulation {
                            return .empty()
                        }
                        return signatureNotificationHandler.observeSignatureNotification(signature: signature)
                    }
                    .andThen(
                        Single<(from: PublicKey, to: PublicKey, cleanupInstructions: [TransactionInstruction])>.just((from: from.account, to: to.account, cleanupInstructions: from.cleanupInstructions + to.cleanupInstructions))
                    )
            }
    }
}

private extension Decimal {
    var doubleValue: Double {
        return NSDecimalNumber(decimal:self).doubleValue
    }
}
