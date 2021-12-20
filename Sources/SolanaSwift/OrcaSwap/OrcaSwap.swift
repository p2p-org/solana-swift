//
//  OrcaSwap.swift
//  
//
//  Created by Chung Tran on 13/10/2021.
//

import Foundation
import RxSwift

private var cache: OrcaSwap.SwapInfo?

public protocol OrcaSwapType {
    func load() -> Completable
    func findPosibleDestinationMints(fromMint: String) throws -> [String]
    func getTradablePoolsPairs(fromMint: String, toMint: String) -> Single<[OrcaSwap.PoolsPair]>
    func findBestPoolsPairForInputAmount(_ inputAmount: UInt64,from poolsPairs: [OrcaSwap.PoolsPair]) throws -> OrcaSwap.PoolsPair?
    func findBestPoolsPairForEstimatedAmount(_ estimatedAmount: UInt64,from poolsPairs: [OrcaSwap.PoolsPair]) throws -> OrcaSwap.PoolsPair?
    func getFees(
        myWalletsMints: [String],
        fromWalletPubkey: String,
        toWalletPubkey: String?,
        feeRelayerFeePayerPubkey: String?,
        bestPoolsPair: OrcaSwap.PoolsPair?,
        inputAmount: Double?,
        slippage: Double,
        lamportsPerSignature: UInt64,
        minRentExempt: UInt64
    ) throws -> (transactionFees: UInt64, liquidityProviderFees: [UInt64])
    func swap(
        fromWalletPubkey: String,
        toWalletPubkey: String?,
        bestPoolsPair: OrcaSwap.PoolsPair,
        amount: Double,
        slippage: Double,
        isSimulation: Bool
    ) -> Single<OrcaSwap.SwapResponse>
}

public class OrcaSwap: OrcaSwapType {
    // MARK: - Properties
    let apiClient: OrcaSwapAPIClient
    let solanaClient: OrcaSwapSolanaClient
    let accountProvider: OrcaSwapAccountProvider
    let notificationHandler: OrcaSwapSignatureConfirmationHandler
    
    var info: OrcaSwap.SwapInfo?
    private let lock = NSLock()
    
    // MARK: - Initializer
    public init(
        apiClient: OrcaSwapAPIClient,
        solanaClient: OrcaSwapSolanaClient,
        accountProvider: OrcaSwapAccountProvider,
        notificationHandler: OrcaSwapSignatureConfirmationHandler
    ) {
        self.apiClient = apiClient
        self.solanaClient = solanaClient
        self.accountProvider = accountProvider
        self.notificationHandler = notificationHandler
    }
    
    // MARK: - Methods
    /// Prepare all needed infos for swapping
    public func load() -> Completable {
        if info != nil {return .empty()}
        return Single.zip(
            apiClient.getTokens(),
            apiClient.getPools(),
            apiClient.getProgramID()
        )
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .map { tokens, pools, programId -> SwapInfo in
                let routes = findAllAvailableRoutes(tokens: tokens, pools: pools)
                let tokenNames = tokens.reduce([String: String]()) { result, token in
                    var result = result
                    result[token.value.mint] = token.key
                    return result
                }
                return .init(
                    routes: routes,
                    tokens: tokens,
                    pools: pools,
                    programIds: programId,
                    tokenNames: tokenNames
                )
            }
            .do(onSuccess: {[weak self] info in
                self?.lock.lock()
                self?.info = info
                self?.lock.unlock()
            })
            .asCompletable()
    }
    
    /// Find posible destination tokens by mint
    /// - Parameter fromMint: from token mint
    /// - Returns: List of token mints that can be swapped to
    public func findPosibleDestinationMints(
        fromMint: String
    ) throws -> [String] {
        guard let fromTokenName = getTokenFromMint(fromMint)?.name
        else {throw OrcaSwapError.notFound}
        
        let routes = try findRoutes(fromTokenName: fromTokenName, toTokenName: nil)
        return routes.keys.compactMap {$0.components(separatedBy: "/")
            .first(where: {!$0.contains(fromTokenName)})}
            .unique
            .compactMap {info?.tokens[$0]?.mint}
    }
    
    /// Get all tradable pools pairs for current token pair
    /// - Returns: route and parsed pools
    public func getTradablePoolsPairs(
        fromMint: String,
        toMint: String
    ) -> Single<[PoolsPair]> {
        guard let fromTokenName = getTokenFromMint(fromMint)?.name,
              let toTokenName = getTokenFromMint(toMint)?.name,
              let currentRoutes = try? findRoutes(fromTokenName: fromTokenName, toTokenName: toTokenName)
                .first?.value
        else {return .just([])}
        
        // retrieve all routes
        let requests: [Single<[Pool]>] = currentRoutes.compactMap {
            guard $0.count <= 2 else {return nil} // FIXME: Support more than 2 paths later
            return info?.pools.getPools(
                forRoute: $0,
                fromTokenName: fromTokenName,
                toTokenName: toTokenName,
                solanaClient: solanaClient
            )
        }
        
        return Single.zip(requests)
    }
    
    /// Find best pool to swap from input amount
    public func findBestPoolsPairForInputAmount(
        _ inputAmount: UInt64,
        from poolsPairs: [PoolsPair]
    ) throws -> PoolsPair? {
//        var poolsPairs = poolsPairs
//
//        // filter out deprecated pools
//        let indeprecatedPools = poolsPairs.filter {!$0.contains(where: {$0.deprecated == true})}
//        if indeprecatedPools.count > 0 {
//            poolsPairs = indeprecatedPools
//        }
        
        guard poolsPairs.count > 0 else {return nil}
        
        var bestPools: [Pool]?
        var bestEstimatedAmount: UInt64 = 0
        
        for pair in poolsPairs {
            guard let estimatedAmount = pair.getOutputAmount(fromInputAmount: inputAmount)
            else {continue}
            if estimatedAmount > bestEstimatedAmount {
                bestEstimatedAmount = estimatedAmount
                bestPools = pair
            }
        }
        
        return bestPools
    }
    
    /// Find best pool to swap from estimated amount
    public func findBestPoolsPairForEstimatedAmount(
        _ estimatedAmount: UInt64,
        from poolsPairs: [PoolsPair]
    ) throws -> PoolsPair? {
//        var poolsPairs = poolsPairs
//        
//        // filter out deprecated pools
//        let indeprecatedPools = poolsPairs.filter {!$0.contains(where: {$0.deprecated == true})}
//        if indeprecatedPools.count > 0 {
//            poolsPairs = indeprecatedPools
//        }
        
        guard poolsPairs.count > 0 else {return nil}
        
        var bestPools: [Pool]?
        var bestInputAmount: UInt64 = .max
        
        for pair in poolsPairs {
            guard let inputAmount = pair.getInputAmount(fromEstimatedAmount: estimatedAmount)
            else {continue}
            if inputAmount < bestInputAmount {
                bestInputAmount = inputAmount
                bestPools = pair
            }
        }
        
        return bestPools
    }
    
    /// Get fees from current context
    /// - Returns: transactions fees (fees for signatures), liquidity provider fees (fees in intermediary token?, fees in destination token)
    public func getFees(
        myWalletsMints: [String],
        fromWalletPubkey: String,
        toWalletPubkey: String?,
        feeRelayerFeePayerPubkey: String?,
        bestPoolsPair: OrcaSwap.PoolsPair?,
        inputAmount: Double?,
        slippage: Double,
        lamportsPerSignature: UInt64,
        minRentExempt: UInt64
    ) throws -> (transactionFees: UInt64, liquidityProviderFees: [UInt64]) {
        guard let owner = accountProvider.getNativeWalletAddress() else {throw OrcaSwapError.unauthorized}
        
        var transactionFees: UInt64 = 0
        
        let numberOfPools = UInt64(bestPoolsPair?.count ?? 0)
        var numberOfTransactions: UInt64 = 1
        
        if numberOfPools == 2 {
            let myTokens = myWalletsMints.compactMap {getTokenFromMint($0)}.map {$0.name}
            let intermediaryTokenName = bestPoolsPair![0].tokenBName
            
            if !myTokens.contains(intermediaryTokenName) ||
                toWalletPubkey == nil
            {
                numberOfTransactions += 1
            }
        }
        
        // owner's signatures
        transactionFees += lamportsPerSignature * numberOfTransactions
        
        if feeRelayerFeePayerPubkey == nil {
            // userAuthoritys' signatures
            transactionFees += lamportsPerSignature * numberOfPools
        } else {
            fatalError("feeRelayer is being implemented")
        }
        
        // when swap from or to native SOL, a fee for creating it is needed
        if fromWalletPubkey == owner.base58EncodedString || toWalletPubkey == owner.base58EncodedString
        {
            transactionFees += lamportsPerSignature
            transactionFees += minRentExempt
        }
        
        // when intermediary token is SOL, a fee for creating WSOL is needed
        if numberOfPools == 2,
           let decimals = bestPoolsPair![0].tokenABalance?.decimals,
           let inputAmount = inputAmount,
           let intermediaryToken = bestPoolsPair?
                .getIntermediaryToken(
                    inputAmount: inputAmount.toLamport(decimals: decimals),
                    slippage: slippage
                ),
           intermediaryToken.tokenName == "SOL"
        {
            transactionFees += lamportsPerSignature
            transactionFees += minRentExempt
        }
        
        var liquidityProviderFees = [UInt64]()
        if let inputAmount = inputAmount {
            liquidityProviderFees = try bestPoolsPair?.calculateLiquidityProviderFees(inputAmount: inputAmount, slippage: slippage) ?? []
        }
        
        return (transactionFees: transactionFees, liquidityProviderFees: liquidityProviderFees)
    }
    
    /// Execute swap
    public func swap(
        fromWalletPubkey: String,
        toWalletPubkey: String?,
        bestPoolsPair: PoolsPair,
        amount: Double,
        slippage: Double,
        isSimulation: Bool = false
    ) -> Single<SwapResponse> {
        guard bestPoolsPair.count > 0 else {return .error(OrcaSwapError.swapInfoMissing)}
        guard let fromDecimals = bestPoolsPair[0].tokenABalance?.decimals else {
            return .error(OrcaSwapError.invalidPool)
        }
        
        let amount = amount.toLamport(decimals: fromDecimals)
        
        var feeRelayerFeePayer: PublicKey? // TODO: - Fee relayer
        
        if bestPoolsPair.count == 1 {
            return directSwap(
                pool: bestPoolsPair[0],
                fromTokenPubkey: fromWalletPubkey,
                toTokenPubkey: toWalletPubkey,
                amount: amount,
                slippage: slippage,
                feeRelayerFeePayer: feeRelayerFeePayer,
                isSimulation: isSimulation
            )
        } else {
            let pool0 = bestPoolsPair[0]
            let pool1 = bestPoolsPair[1]
            
            // TO AVOID `TRANSACTION IS TOO LARGE` ERROR, WE SPLIT OPERATION INTO 2 TRANSACTIONS
            // FIRST TRANSACTION IS TO CREATE ASSOCIATED TOKEN ADDRESS FOR INTERMEDIARY TOKEN OR DESTINATION TOKEN (IF NOT YET CREATED) AND WAIT FOR CONFIRMATION **IF THEY ARE NOT WSOL**
            // SECOND TRANSACTION TAKE THE RESULT OF FIRST TRANSACTION (ADDRESSES) TO REDUCE ITS SIZE. **IF INTERMEDIATE TOKEN OR DESTINATION TOKEN IS WSOL, IT SHOULD BE INCLUDED IN THIS TRANSACTION**
            
            // First transaction
            return createIntermediaryTokenAndDestinationTokenAddressIfNeeded(
                pool0: pool0,
                pool1: pool1,
                toWalletPubkey: toWalletPubkey,
                feeRelayerFeePayer: feeRelayerFeePayer
            )
                .flatMap {[weak self] intermediaryTokenAddress, destinationTokenAddress, wsolAccountInstructions in
                    guard let self = self else {throw OrcaSwapError.unknown}
                    // Second transaction
                    return self.transitiveSwap(
                        pool0: pool0,
                        pool1: pool1,
                        fromTokenPubkey: fromWalletPubkey,
                        intermediaryTokenAddress: intermediaryTokenAddress.base58EncodedString,
                        destinationTokenAddress: destinationTokenAddress.base58EncodedString,
                        wsolAccountInstructions: wsolAccountInstructions,
                        isDestinationNew: toWalletPubkey == nil,
                        amount: amount,
                        slippage: slippage,
                        feeRelayerFeePayer: feeRelayerFeePayer,
                        isSimulation: isSimulation
                    )
                }
        }
    }
    
    /// Find routes for from and to token name, aka symbol
    func findRoutes(
        fromTokenName: String?,
        toTokenName: String?
    ) throws -> Routes {
        guard let info = info else { throw OrcaSwapError.swapInfoMissing }
        
        // if fromToken isn't selected
        guard let fromTokenName = fromTokenName else {return [:]}

        // if toToken isn't selected
        guard let toTokenName = toTokenName else {
            // get all routes that have token A
            let routes = info.routes.filter {$0.key.components(separatedBy: "/").contains(fromTokenName)}
                .filter {!$0.value.isEmpty}
            return routes
        }

        // get routes with fromToken and toToken
        let pair = [fromTokenName, toTokenName]
        let validRoutesNames = [
            pair.joined(separator: "/"),
            pair.reversed().joined(separator: "/")
        ]
        return info.routes.filter {validRoutesNames.contains($0.key)}
            .filter {!$0.value.isEmpty}
    }
    
    /// Map mint to token info
    private func getTokenFromMint(_ mint: String) -> (name: String, info: Token)? {
        let tokenInfo = info?.tokens.first(where: {$0.value.mint == mint})
        guard let name = tokenInfo?.key, let value = tokenInfo?.value else {return nil}
        return (name: name, info: value)
    }
    
    private func directSwap(
        pool: Pool,
        fromTokenPubkey: String,
        toTokenPubkey: String?,
        amount: UInt64,
        slippage: Double,
        feeRelayerFeePayer: PublicKey?,
        isSimulation: Bool
    ) -> Single<SwapResponse> {
        guard let owner = accountProvider.getAccount() else {return .error(OrcaSwapError.unauthorized)}
        guard let info = info else {return .error(OrcaSwapError.swapInfoMissing)}
        
        return pool
            .constructExchange(
                tokens: info.tokens,
                solanaClient: solanaClient,
                owner: owner,
                fromTokenPubkey: fromTokenPubkey,
                toTokenPubkey: toTokenPubkey,
                amount: amount,
                slippage: slippage,
                feeRelayerFeePayer: feeRelayerFeePayer,
                shouldCreateAssociatedTokenAccount: true
            )
            .flatMap {[weak self] accountInstructions in
                guard let self = self else {throw OrcaSwapError.unknown}
                
                if let feePayer = feeRelayerFeePayer {
                    fatalError("Fee relayer is implementing")
                } else {
                    return self.solanaClient.serializeAndSend(
                        instructions: accountInstructions.instructions + accountInstructions.cleanupInstructions,
                        recentBlockhash: nil,
                        signers: [owner] + accountInstructions.signers,
                        isSimulation: isSimulation
                    )
                    .map {.init(transactionId: $0, newWalletPubkey: toTokenPubkey == nil ? accountInstructions.account.base58EncodedString: nil)}
                }
            }
    }
    
    private func transitiveSwap(
        pool0: Pool,
        pool1: Pool,
        fromTokenPubkey: String,
        intermediaryTokenAddress: String,
        destinationTokenAddress: String,
        wsolAccountInstructions: AccountInstructions?,
        isDestinationNew: Bool,
        amount: UInt64,
        slippage: Double,
        feeRelayerFeePayer: PublicKey?,
        isSimulation: Bool
    ) -> Single<SwapResponse> {
        guard let owner = accountProvider.getAccount() else {return .error(OrcaSwapError.unauthorized)}
        guard let info = info else {return .error(OrcaSwapError.swapInfoMissing)}
        
        return pool0
            .constructExchange(
                tokens: info.tokens,
                solanaClient: self.solanaClient,
                owner: owner,
                fromTokenPubkey: fromTokenPubkey,
                toTokenPubkey: intermediaryTokenAddress,
                amount: amount,
                slippage: slippage,
                feeRelayerFeePayer: feeRelayerFeePayer,
                shouldCreateAssociatedTokenAccount: false
            )
            .flatMap {[weak self] pool0AccountInstructions -> Single<AccountInstructions> in
                guard let self = self,
                      let amount = try pool0.getMinimumAmountOut(inputAmount: amount, slippage: slippage)
                else {throw OrcaSwapError.unknown}
                
                return pool1.constructExchange(
                    tokens: info.tokens,
                    solanaClient: self.solanaClient,
                    owner: owner,
                    fromTokenPubkey: intermediaryTokenAddress,
                    toTokenPubkey: destinationTokenAddress,
                    amount: amount,
                    slippage: slippage,
                    feeRelayerFeePayer: feeRelayerFeePayer,
                    shouldCreateAssociatedTokenAccount: false
                )
                .map {pool1AccountInstructions in
                    .init(
                        account: pool1AccountInstructions.account,
                        instructions: pool0AccountInstructions.instructions + pool1AccountInstructions.instructions,
                        cleanupInstructions: pool0AccountInstructions.cleanupInstructions + pool1AccountInstructions.cleanupInstructions,
                        signers: pool0AccountInstructions.signers + pool1AccountInstructions.signers
                    )
                }
            }
            .flatMap {[weak self] accountInstructions in
                guard let self = self else {throw OrcaSwapError.unknown}
                
                var instructions = accountInstructions.instructions + accountInstructions.cleanupInstructions
                if let wsolAccountInstructions = wsolAccountInstructions {
                    instructions.insert(contentsOf: wsolAccountInstructions.instructions, at: 0)
                    instructions.append(contentsOf: wsolAccountInstructions.cleanupInstructions)
                }
                
                if let feePayer = feeRelayerFeePayer {
                    fatalError("Fee relayer is implementing")
                } else {
                    return self.solanaClient.serializeAndSend(
                        instructions: instructions,
                        recentBlockhash: nil,
                        signers: [owner] + accountInstructions.signers,
                        isSimulation: isSimulation
                    )
                    .map {.init(transactionId: $0, newWalletPubkey: isDestinationNew ? accountInstructions.account.base58EncodedString: nil)}
                }
            }
            .retry { errors in
                errors.enumerated().flatMap{ (index, error) -> Observable<Int64> in
                    if error.readableDescription == "InvalidAccountData" {
                        return .timer(.seconds(1), scheduler: MainScheduler.instance)
                    }
                    return .error(error)
                }
            }
            .timeout(.seconds(60), scheduler: MainScheduler.instance)
    }
    
    private func createIntermediaryTokenAndDestinationTokenAddressIfNeeded(
        pool0: Pool,
        pool1: Pool,
        toWalletPubkey: String?,
        feeRelayerFeePayer: PublicKey?
    ) -> Single<(PublicKey, PublicKey, AccountInstructions?)> /*intermediaryTokenAddress, destination token address, WSOL account and instructions*/ {
        
        guard let owner = accountProvider.getAccount(),
              let intermediaryTokenMint = try? info?.tokens[pool0.tokenBName]?.mint.toPublicKey(),
              let destinationMint = try? info?.tokens[pool1.tokenBName]?.mint.toPublicKey()
        else {return .error(OrcaSwapError.unauthorized)}
        
        return Single.zip(
            solanaClient.prepareForCreatingAssociatedTokenAccount(
                owner: owner.publicKey,
                mint: intermediaryTokenMint,
                feePayer: feeRelayerFeePayer ?? owner.publicKey,
                closeAfterward: true
            ),
            solanaClient.prepareForCreatingAssociatedTokenAccount(
                owner: owner.publicKey,
                mint: destinationMint,
                feePayer: feeRelayerFeePayer ?? owner.publicKey,
                closeAfterward: false
            )
        )
            .flatMap { intAccountInstructions, desAccountInstructions -> Single<(PublicKey, PublicKey, AccountInstructions?)> in
                // get all creating instructions, PASS WSOL ACCOUNT INSTRUCTIONS TO THE SECOND TRANSACTION
                var instructions = [TransactionInstruction]()
                var wsolAccountInstructions: AccountInstructions?
                if intermediaryTokenMint == .wrappedSOLMint {
                    wsolAccountInstructions = intAccountInstructions
                } else {
                    instructions.append(contentsOf: intAccountInstructions.instructions)
                }
                if destinationMint == .wrappedSOLMint {
                    wsolAccountInstructions = desAccountInstructions
                } else {
                    instructions.append(contentsOf: desAccountInstructions.instructions)
                }
                
                // if token address has already been created, then no need to send any transactions
                if instructions.isEmpty {
                    return .just((intAccountInstructions.account, desAccountInstructions.account, wsolAccountInstructions))
                }
                
                // if creating transaction is needed
                else {
                    if let feePayer = feeRelayerFeePayer {
                        fatalError("Fee relayer is implementing")
                    } else {
                        return self.solanaClient.serializeAndSend(
                            instructions: instructions,
                            recentBlockhash: nil,
                            signers: [owner],
                            isSimulation: false // FIXME
                        )
                            // wait for confirmation and return the addresses
                            .flatMapCompletable { [weak self] txid in
                                guard let self = self else {throw OrcaSwapError.unknown}
                                return self.notificationHandler.waitForConfirmation(signature: txid)
                            }
                            .andThen(.just((intAccountInstructions.account, desAccountInstructions.account, wsolAccountInstructions)))
                    }
                }
            }
    }
}

// MARK: - Helpers

private func findAllAvailableRoutes(tokens: OrcaSwap.Tokens, pools: OrcaSwap.Pools) -> OrcaSwap.Routes {
    let tokens = tokens.filter {$0.value.poolToken != true}
        .map {$0.key}
    let pairs = getPairs(tokens: tokens)
    return getAllRoutes(pairs: pairs, pools: pools)
}

private func getPairs(tokens: [String]) -> [[String]] {
    var pairs = [[String]]()
    
    guard tokens.count > 0 else {return pairs}
    
    for i in 0..<tokens.count-1 {
        for j in i+1..<tokens.count {
            let tokenA = tokens[i]
            let tokenB = tokens[j]
            
            pairs.append(orderTokenPair(tokenA, tokenB))
        }
    }
    
    return pairs
}

private func orderTokenPair(_ tokenX: String, _ tokenY: String) -> [String] {
    if (tokenX == "USDC" && tokenY == "USDT") {
        return [tokenX, tokenY];
    } else if (tokenY == "USDC" && tokenX == "USDT") {
        return [tokenY, tokenX];
    } else if (tokenY == "USDC" || tokenY == "USDT") {
        return [tokenX, tokenY];
    } else if (tokenX == "USDC" || tokenX == "USDT") {
        return [tokenY, tokenX];
    } else if tokenX < tokenY {
        return [tokenX, tokenY];
    } else {
        return [tokenY, tokenX];
    }
}

private func getAllRoutes(pairs: [[String]], pools: OrcaSwap.Pools) -> OrcaSwap.Routes {
    var routes: OrcaSwap.Routes = [:]
    pairs.forEach { pair in
        guard let tokenA = pair.first,
              let tokenB = pair.last
        else {return}
        routes[getTradeId(tokenA, tokenB)] = getRoutes(tokenA: tokenA, tokenB: tokenB, pools: pools)
    }
    return routes
}

private func getTradeId(_ tokenX: String, _ tokenY: String) -> String {
    orderTokenPair(tokenX, tokenY).joined(separator: "/")
}

private func getRoutes(tokenA: String, tokenB: String, pools: OrcaSwap.Pools) -> [OrcaSwap.Route] {
    var routes = [OrcaSwap.Route]()
    
    // Find all pools that contain the same tokens.
    // Checking tokenAName and tokenBName will find Stable pools.
    for (poolId, poolConfig) in pools {
        if (poolConfig.tokenAName == tokenA && poolConfig.tokenBName == tokenB) ||
            (poolConfig.tokenAName == tokenB && poolConfig.tokenBName == tokenA)
        {
            routes.append([poolId])
        }
    }
    
    // Find all pools that contain the first token but not the second
    let firstLegPools = pools
        .filter {
            ($0.value.tokenAName == tokenA && $0.value.tokenBName != tokenB) ||
                ($0.value.tokenBName == tokenA && $0.value.tokenAName != tokenB)
        }
        .reduce([String: String]()) { result, pool in
            var result = result
            result[pool.key] = pool.value.tokenBName == tokenA ? pool.value.tokenAName: pool.value.tokenBName
            return result
        }
    
    // Find all routes that can include firstLegPool and a second pool.
    firstLegPools.forEach { firstLegPoolId, intermediateTokenName in
        pools.forEach { secondLegPoolId, poolConfig in
            if (poolConfig.tokenAName == intermediateTokenName && poolConfig.tokenBName == tokenB) ||
                (poolConfig.tokenBName == intermediateTokenName && poolConfig.tokenAName == tokenB)
            {
                routes.append([firstLegPoolId, secondLegPoolId])
            }
        }
    }
    
    return routes
}
