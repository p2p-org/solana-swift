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
    public func loadMarket(fromMint: PublicKey, toMint: PublicKey) -> Single<[Market]> {
        route(fromMint: fromMint, toMint: toMint)
            .flatMap {route -> Single<[Market]> in
                guard let route = route else {
                    throw SerumSwapError.couldNotRetrieveExchangeRate
                }
                let singles = route.map {loadMarket(address: $0)}
                return Single.zip(singles)
            }
    }
    
    /// Load price of current two pair
    public func loadPrice(fromMint: PublicKey, toMint: PublicKey) -> Single<Decimal> {
        loadMarket(fromMint: fromMint, toMint: toMint)
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
                    return try bbo.definePrice(fromMint: fromMint, toMint: toMint)
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
            address: coinWallet,
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
                        minRentExemption: minRentExemption,
                        closeAfterward: CLOSE_ENABLED && close == true && fromOpenOrders == nil
                    ),
                    prepareOpenOrder(
                        orders: toOpenOrders,
                        market: toMarket,
                        minRentExemption: minRentExemption,
                        closeAfterward: CLOSE_ENABLED && close == true && toOpenOrders == nil
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
                Self.transitiveSwapInstruction(
                    authority: owner,
                    fromMarket: fromMarket,
                    toMarket: toMarket,
                    fromVaultSigner: fromVaultSigner,
                    toVaultSigner: toVaultSigner,
                    fromOpenOrder: fromOpenOrdersAccountInstructions.account,
                    toOpenOrder: toOpenOrdersAccountInstructions.account,
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
                instructions += fromOpenOrdersAccountInstructions.cleanupInstructions
                instructions += toOpenOrdersAccountInstructions.cleanupInstructions
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
    
    /// Returns a list of markets to trade across to swap `fromMint` to `toMint`.
    func route(fromMint: PublicKey, toMint: PublicKey) -> Single<[PublicKey]?> {
        swapMarkets.route(fromMint: fromMint, toMint: toMint)
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
}
