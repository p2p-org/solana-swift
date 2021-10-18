//
//  File.swift
//  
//
//  Created by Chung Tran on 13/10/2021.
//

import Foundation
import RxSwift

private let N_COINS: UInt64 = 2
private let N_COINS_SQUARED: UInt64 = 4
private let STABLE = "Stable"
private let CONSTANT_PRODUCT = "ConstantProduct"

public extension OrcaSwap {
    struct Pool: Decodable, Equatable {
        let account: String
        let authority: String
        let nonce: UInt64
        let poolTokenMint: String
        var tokenAccountA: String
        var tokenAccountB: String
        let feeAccount: String
        let hostFeeAccount: String?
        let feeNumerator: UInt64
        let feeDenominator: UInt64
        let ownerTradeFeeNumerator: UInt64
        let ownerTradeFeeDenominator: UInt64
        let ownerWithdrawFeeNumerator: UInt64
        let ownerWithdrawFeeDenominator: UInt64
        let hostFeeNumerator: UInt64
        let hostFeeDenominator: UInt64
        var tokenAName: String
        var tokenBName: String
        let curveType: String
        let amp: UInt64?
        let programVersion: UInt64?
        let deprecated: Bool?
        
        // balance (lazy load)
        var tokenABalance: SolanaSDK.TokenAccountBalance?
        var tokenBBalance: SolanaSDK.TokenAccountBalance?
        
        var isStable: Bool?
        
        var reversed: Pool {
            var reversedPool = self
            Swift.swap(&reversedPool.tokenAccountA, &reversedPool.tokenAccountB)
            Swift.swap(&reversedPool.tokenAName, &reversedPool.tokenBName)
            Swift.swap(&reversedPool.tokenABalance, &reversedPool.tokenBBalance)
            return reversedPool
        }
        
        func getOutputAmount(
            fromInputAmount inputAmount: UInt64
        ) throws -> UInt64? {
            guard let poolInputAmount = tokenABalance?.amountInUInt64,
                  let poolOutputAmount = tokenBBalance?.amountInUInt64
            else {throw OrcaSwapError.accountBalanceNotFound}
            
            let fees = try getFee(inputAmount)
            let inputAmountLessFee = inputAmount - fees
            
            switch curveType {
            case STABLE:
                guard let amp = amp else {throw OrcaSwapError.ampDoesNotExistInPoolConfig}
                return computeOutputAmount(
                    inputAmount: inputAmountLessFee,
                    inputPoolAmount: poolInputAmount,
                    outputPoolAmount: poolOutputAmount,
                    amp: amp
                )
            case CONSTANT_PRODUCT:
                let invariant = BInt(poolInputAmount) * BInt(poolOutputAmount)
                let newPoolOutputAmount = ceilingDivision(invariant, BInt(poolInputAmount + inputAmountLessFee)).quotient
                return poolOutputAmount - newPoolOutputAmount
            default:
                return nil
            }
        }
        
        func getInputAmount(
            fromEstimatedAmount estimatedAmount: UInt64
        ) throws -> UInt64? {
            guard let poolInputAmount = tokenABalance?.amountInUInt64,
                  let poolOutputAmount = tokenBBalance?.amountInUInt64
            else {throw OrcaSwapError.accountBalanceNotFound}
            
            if estimatedAmount > poolOutputAmount {
                throw OrcaSwapError.estimatedAmountIsTooHigh
            }
            
            switch curveType {
            case STABLE:
                guard let amp = amp else {throw OrcaSwapError.ampDoesNotExistInPoolConfig}
                let inputAmountLessFee = computeInputAmount(outputAmount: estimatedAmount, inputPoolAmount: poolInputAmount, outputPoolAmount: poolOutputAmount, amp: amp)
                let inputAmount = BInt(inputAmountLessFee) * BInt(feeDenominator) / BInt(feeDenominator - feeNumerator)
                return UInt64(inputAmount)
            case CONSTANT_PRODUCT:
                let invariant = BInt(poolInputAmount) * BInt(poolOutputAmount)
                
                let newPoolInputAmount = ceilingDivision(invariant, BInt(poolOutputAmount - estimatedAmount)).quotient
                let inputAmountLessFee = BInt(newPoolInputAmount - poolInputAmount)
                
                let feeRatioNumerator: BInt
                let feeRatioDenominator: BInt
                
                if ownerTradeFeeDenominator == 0 {
                    feeRatioNumerator = BInt(feeDenominator)
                    feeRatioDenominator = BInt(feeDenominator - feeNumerator)
                } else {
                    feeRatioNumerator = BInt(feeDenominator) * BInt(ownerTradeFeeDenominator)
                    feeRatioDenominator = BInt(feeDenominator)
                        * BInt(ownerTradeFeeDenominator)
                        - (BInt(feeNumerator) * BInt(ownerTradeFeeDenominator))
                        - (BInt(ownerTradeFeeNumerator) * BInt(feeDenominator))
                }
                
                let inputAmount = inputAmountLessFee * feeRatioNumerator / feeRatioDenominator
                return UInt64(inputAmount)
                
            default:
                return nil
            }
        }
        
        func getMinimumAmountOut(
            inputAmount: UInt64,
            slippage: Double
        ) throws -> UInt64? {
            guard let estimatedOutputAmount = try getOutputAmount(fromInputAmount: inputAmount)
            else {return nil}
            return UInt64(Float64(estimatedOutputAmount) * Float64(1 - slippage))
        }
        
        /// baseOutputAmount is the amount the user would receive if fees are included and slippage is excluded.
        func getBaseOutputAmount(
            inputAmount: UInt64
        ) throws -> UInt64? {
            guard let poolInputAmount = tokenABalance?.amountInUInt64,
                  let poolOutputAmount = tokenBBalance?.amountInUInt64
            else {throw OrcaSwapError.accountBalanceNotFound}
            
            let fees = try getFee(inputAmount)
            let inputAmountLessFee = inputAmount - fees
            
            switch curveType {
            case STABLE:
                guard let amp = amp else {throw OrcaSwapError.ampDoesNotExistInPoolConfig}
                return computeBaseOutputAmount(
                    inputAmount: inputAmountLessFee,
                    inputPoolAmount: poolInputAmount,
                    outputPoolAmount: poolOutputAmount,
                    amp: amp
                )
            case CONSTANT_PRODUCT:
                return UInt64(BInt(inputAmountLessFee) * BInt(poolOutputAmount) / BInt(poolInputAmount))
            default:
                return nil
            }
        }
        
        /// Construct exchange
        func constructExchange(
            tokens: Tokens,
            solanaClient: OrcaSwapSolanaClient,
            owner: Account,
            fromTokenPubkey: String,
            toTokenPubkey: String?,
            amount: Lamports,
            slippage: Double,
            feeRelayerFeePayer: PublicKey?
        ) -> Single<AccountInstructions> {
            guard let fromMint = try? tokens[tokenAName]?.mint.toPublicKey(),
                  let toMint = try? tokens[tokenBName]?.mint.toPublicKey(),
                  let fromTokenPubkey = try? fromTokenPubkey.toPublicKey()
            else {return .error(OrcaSwapError.notFound)}
            
            // prepare source
            let prepareSourceRequest = solanaClient.prepareSourceAccountAndInstructions(
                myNativeWallet: owner.publicKey,
                source: fromTokenPubkey,
                sourceMint: fromMint,
                amount: amount,
                feePayer: feeRelayerFeePayer ?? owner.publicKey
            )
            
            // prepare destination
            let prepareDestinationRequest: Single<AccountInstructions>
            if let destination = try? toTokenPubkey?.toPublicKey() {
                prepareDestinationRequest = .just(.init(account: destination))
            } else {
                prepareDestinationRequest = solanaClient.prepareDestinationAccountAndInstructions(
                    myAccount: owner.publicKey,
                    destination: try? toTokenPubkey?.toPublicKey(),
                    destinationMint: toMint,
                    feePayer: feeRelayerFeePayer ?? owner.publicKey,
                    closeAfterward: false // FIXME: Check later
                )
            }
            
            return Single.zip(
                prepareSourceRequest,
                prepareDestinationRequest
            )
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .map { sourceAccountInstructions, destinationAccountInstructions -> AccountInstructions in
                // form instructions
                var instructions = [TransactionInstruction]()
                var cleanupInstructions = [TransactionInstruction]()
                
                // source
                instructions.append(contentsOf: sourceAccountInstructions.instructions)
                cleanupInstructions.append(contentsOf: sourceAccountInstructions.cleanupInstructions)
                
                // destination
                instructions.append(contentsOf: destinationAccountInstructions.instructions)
                cleanupInstructions.append(contentsOf: destinationAccountInstructions.cleanupInstructions)
                
                // userTransferAuthorityPubkey
                let userTransferAuthority = try Account(network: solanaClient.endpoint.network)
                var userTransferAuthorityPubkey = userTransferAuthority.publicKey
                
                if feeRelayerFeePayer == nil {
                    // approve (if send without feeRelayer)
                    let approveTransaction = TokenProgram.approveInstruction(
                        tokenProgramId: .tokenProgramId,
                        account: sourceAccountInstructions.account,
                        delegate: userTransferAuthorityPubkey,
                        owner: owner.publicKey,
                        amount: amount
                    )
                    instructions.append(approveTransaction)
                } else {
                    userTransferAuthorityPubkey = owner.publicKey
                }
                
                // swap
                guard let minAmountOut = try? getMinimumAmountOut(inputAmount: amount, slippage: slippage)
                else {throw OrcaSwapError.couldNotEstimatedMinimumOutAmount}
                
                let swapInstruction = TokenSwapProgram.swapInstruction(
                    tokenSwap: try account.toPublicKey(),
                    authority: try authority.toPublicKey(),
                    userTransferAuthority: userTransferAuthorityPubkey,
                    userSource: sourceAccountInstructions.account,
                    poolSource: try tokenAccountA.toPublicKey(),
                    poolDestination: try tokenAccountB.toPublicKey(),
                    userDestination: destinationAccountInstructions.account,
                    poolMint: try poolTokenMint.toPublicKey(),
                    feeAccount: try feeAccount.toPublicKey(),
                    hostFeeAccount: try? hostFeeAccount?.toPublicKey(),
                    swapProgramId: .orcaSwapId,
                    tokenProgramId: .tokenProgramId,
                    amountIn: amount,
                    minimumAmountOut: minAmountOut
                )
                
                instructions.append(swapInstruction)
                
                // send to proxy
                if feeRelayerFeePayer != nil {
                    fatalError("Fee Relayer is implementing")
                }
                
                // send without proxy
                else {
                    var signers = [userTransferAuthority]
                    signers.append(contentsOf: sourceAccountInstructions.signers)
                    signers.append(contentsOf: destinationAccountInstructions.signers)
                    
                    return .init(
                        account: destinationAccountInstructions.account,
                        instructions: instructions,
                        cleanupInstructions: cleanupInstructions,
                        signers: signers
                    )
                }
            }
        }
        
        // MARK: - Helpers
        func getFee(_ inputAmount: UInt64) throws -> UInt64 {
            guard curveType == STABLE || curveType == CONSTANT_PRODUCT else {throw OrcaSwapError.unknown}
            let tradingFee = computeFee(baseAmount: inputAmount, feeNumerator: feeNumerator, feeDenominator: feeDenominator)
            let ownerFee = computeFee(baseAmount: inputAmount, feeNumerator: ownerTradeFeeNumerator, feeDenominator: ownerTradeFeeDenominator)
            return tradingFee + ownerFee
            
        }
        
        private func computeFee(baseAmount: UInt64, feeNumerator: UInt64, feeDenominator: UInt64) -> UInt64 {
            if feeNumerator == 0 {
                return 0
            }
            return UInt64(BInt(baseAmount) * BInt(feeNumerator) / BInt(feeDenominator))
        }
    }
    
    typealias Pools = [String: Pool] // [poolId: string]: PoolConfig;
    typealias PoolsPair = [Pool]
}

private var balancesCache = [String: SolanaSDK.TokenAccountBalance]()
private let lock = NSLock()

extension OrcaSwap.Pools {
    func getPools(
        forRoute route: OrcaSwap.Route,
        fromTokenName: String,
        toTokenName: String,
        solanaClient: OrcaSwapSolanaClient
    ) -> Single<[OrcaSwap.Pool]> {
        guard route.count > 0 else {return .just([])}
        
        let requests = route.map {fixedPool(forPath: $0, solanaClient: solanaClient)}
        return Single.zip(requests).map {$0.compactMap {$0}}
            .map { pools in
                var pools = pools
                
                // modify orders
                if pools.count == 2 {
                    // reverse order of the 2 pools
                    // Ex: Swap from SOCN -> BTC, but paths are
                    // [
                    //     "BTC/SOL[aquafarm]",
                    //     "SOCN/SOL[stable][aquafarm]"
                    // ]
                    // Need to change to
                    // [
                    //     "SOCN/SOL[stable][aquafarm]",
                    //     "BTC/SOL[aquafarm]"
                    // ]
                    
                    if pools[0].tokenAName != fromTokenName && pools[0].tokenBName != fromTokenName {
                        let temp = pools[0]
                        pools[0] = pools[1]
                        pools[1] = temp
                    }
                }

                // reverse token A and token B in pool if needed
                for i in 0..<pools.count {
                    if i == 0 {
                        var pool = pools[0]
                        if pool.tokenAName.fixedTokenName != fromTokenName.fixedTokenName {
                            pool = pool.reversed
                        }
                        pools[0] = pool
                    }
                    
                    if i == 1 {
                        var pool = pools[1]
                        if pool.tokenBName.fixedTokenName != toTokenName.fixedTokenName {
                            pool = pool.reversed
                        }
                        pools[1] = pool
                    }
                }
                return pools
            }
    }
    
    private func fixedPool(
        forPath path: String, // Ex. BTC/SOL[aquafarm][stable]
        solanaClient: OrcaSwapSolanaClient
    ) -> Single<OrcaSwap.Pool?> {
        guard var pool = self[path] else {return .just(nil)}
        
        if path.contains("[stable]") {
            pool.isStable = true
        }
        
        // get balances
        let getBalancesRequest: Single<(SolanaSDK.TokenAccountBalance, SolanaSDK.TokenAccountBalance)>
        if let tokenABalance = pool.tokenABalance ?? balancesCache[pool.tokenAccountA],
           let tokenBBalance = pool.tokenBBalance ?? balancesCache[pool.tokenAccountB]
        {
            getBalancesRequest = .just((tokenABalance, tokenBBalance))
        } else {
            getBalancesRequest = Single.zip(
                solanaClient.getTokenAccountBalance(pubkey: pool.tokenAccountA, commitment: nil),
                solanaClient.getTokenAccountBalance(pubkey: pool.tokenAccountB, commitment: nil)
            )
        }
        
        return getBalancesRequest
            .do(onSuccess: {
                lock.lock()
                balancesCache[pool.tokenAccountA] = $0
                balancesCache[pool.tokenAccountB] = $1
                lock.unlock()
            })
            .map {tokenABalane, tokenBBalance in
                pool.tokenABalance = tokenABalane
                pool.tokenBBalance = tokenBBalance
                
                return pool
            }
    }
}

public extension OrcaSwap.PoolsPair {
    func getOutputAmount(
        fromInputAmount inputAmount: UInt64
    ) -> UInt64? {
        guard count > 0 else {return nil}
        let pool0 = self[0]
        guard let estimatedAmountOfPool0 = try? pool0.getOutputAmount(fromInputAmount: inputAmount)
        else {return nil}
        
        // direct
        if count == 1 {
            return estimatedAmountOfPool0
        }
        // transitive
        else {
            let pool1 = self[1]
            guard let estimatedAmountOfPool1 = try? pool1.getOutputAmount(fromInputAmount: estimatedAmountOfPool0)
            else {return nil}
            
            return estimatedAmountOfPool1
        }
    }
    
    func getInputAmount(
        fromEstimatedAmount estimatedAmount: UInt64
    ) -> UInt64? {
        guard count > 0 else {return nil}
        
        // direct
        if count == 1 {
            let pool0 = self[0]
            guard let inputAmountOfPool0 = try? pool0.getInputAmount(fromEstimatedAmount: estimatedAmount)
            else {return nil}
            return inputAmountOfPool0
        }
        // transitive
        else {
            let pool1 = self[1]
            guard let inputAmountOfPool1 = try? pool1.getInputAmount(fromEstimatedAmount: estimatedAmount)
            else {return nil}
            let pool0 = self[0]
            
            guard let inputAmountOfPool0 = try? pool0.getInputAmount(fromEstimatedAmount: inputAmountOfPool1)
            else {return nil}
            return inputAmountOfPool0
        }
    }
    
    func getMinimumAmountOut(
        inputAmount: UInt64,
        slippage: Double
    ) -> UInt64? {
        guard count > 0 else {return nil}
        let pool0 = self[0]
        // direct
        if count == 1 {
            guard let minimumAmountOut = try? pool0.getMinimumAmountOut(inputAmount: inputAmount, slippage: slippage)
            else {return nil}
            return minimumAmountOut
        }
        // transitive
        else {
            guard let outputAmountOfPool0 = try? pool0.getOutputAmount(fromInputAmount: inputAmount)
            else {return nil}
            
            let pool1 = self[1]
            guard let minimumAmountOut = try? pool1.getMinimumAmountOut(inputAmount: outputAmountOfPool0, slippage: slippage)
            else {return nil}
            return minimumAmountOut
        }
    }
    
    func getIntermediaryToken(
        inputAmount: UInt64,
        slippage: Double
    ) -> OrcaSwap.InterTokenInfo? {
        guard count > 1 else {return nil}
        let pool0 = self[0]
        return .init(
            tokenName: pool0.tokenBName,
            outputAmount: try? pool0.getOutputAmount(fromInputAmount: inputAmount),
            minAmountOut: try? pool0.getMinimumAmountOut(inputAmount: inputAmount, slippage: slippage),
            isStableSwap: self[1].isStable == true
        )
    }
    
    /// baseOutputAmount is the amount the user would receive if fees are included and slippage is excluded.
    private func getBaseOutputAmount(
        inputAmount: UInt64
    ) -> UInt64? {
        guard count > 0 else {return nil}
        let pool0 = self[0]
        guard let outputAmountOfPool0 = try? pool0.getBaseOutputAmount(inputAmount: inputAmount)
        else {return nil}
        
        // direct
        if count == 1 {
            return outputAmountOfPool0
        }
        // transitive
        else {
            let pool1 = self[1]
            guard let outputAmountOfPool1 = try? pool1.getBaseOutputAmount(inputAmount: outputAmountOfPool0)
            else {return nil}
            
            return outputAmountOfPool1
        }
    }
    
    /// price impact
    func getPriceImpact(
        inputAmount: UInt64,
        outputAmount: UInt64
    ) -> BDouble? {
        guard let baseOutputAmount = getBaseOutputAmount(inputAmount: inputAmount)
        else {return nil}
        
        let inputAmountDecimal = BDouble(inputAmount.convertToBalance(decimals: 0))
        let baseOutputAmountDecimal = BDouble(baseOutputAmount.convertToBalance(decimals: 0))
        
        return (baseOutputAmountDecimal - inputAmountDecimal) / baseOutputAmountDecimal * 100
    }
}

private extension String {
    /// Convert  SOL[aquafarm] to SOL
    var fixedTokenName: String {
        components(separatedBy: "[").first!
    }
}

private func ceilingDivision(_ dividend: BInt, _ divisor: BInt) -> (quotient: UInt64, divisor: UInt64) {
    var divisor = divisor
    var quotient = dividend / divisor
    if quotient == 0 {
        return (quotient: 0, divisor: UInt64(divisor))
    }
    
    var remainder = dividend % divisor
    if remainder > 0 {
        quotient += 1
        divisor = dividend / quotient
        remainder = dividend / quotient
        if remainder > 0 {
            divisor += 1
        }
    }
    
    return (quotient: UInt64(quotient), divisor: UInt64(divisor))
}

private func computeOutputAmount(
    inputAmount: UInt64,
    inputPoolAmount: UInt64,
    outputPoolAmount: UInt64,
    amp: UInt64
) -> UInt64 {
    let leverage = amp * N_COINS
    let newInputPoolAmount = inputAmount + inputPoolAmount
    let d = computeD(leverage: leverage, amountA: inputPoolAmount, amountB: outputPoolAmount)
    
    let newOutputPoolAmount = _computeOutputAmount(leverage: leverage, newInputAmount: newInputPoolAmount, d: d)
    let outputAmount = outputPoolAmount - newOutputPoolAmount
    return outputAmount
}

// A * sum(x_i) * n**n + D = A * D * n**n + D**(n+1) / (n**n * prod(x_i))
private func computeD(leverage: UInt64, amountA: UInt64, amountB: UInt64) -> UInt64 {
    let amountATimesN = BInt(amountA) * BInt(N_COINS) + 1
    let amountBTimesN = BInt(amountB) * BInt(N_COINS) + 1
    let sumX = BInt(amountA) + BInt(amountB)
    
    if sumX == 0 {
        return 0
    }
    
    var dPrevious: BInt
    var d = sumX
    
    for _ in 0..<32 {
        var dProduct = d
        dProduct = dProduct * d / amountATimesN
        dProduct = dProduct * d / amountBTimesN
        dPrevious = d
        d = BInt(calculateStep(initialD: UInt64(d), leverage: leverage, sumX: UInt64(sumX), dProduct: UInt64(dProduct)))
        if d == dPrevious {
            break
        }
    }
    
    return UInt64(d)
}

// d = (leverage * sum_x + d_product * n_coins) * initial_d / ((leverage - 1) * initial_d + (n_coins + 1) * d_product)
private func calculateStep(
  initialD: UInt64,
  leverage: UInt64,
  sumX: UInt64,
  dProduct: UInt64
) -> UInt64 {
    let leverageMul = BInt(leverage) * BInt(sumX)
    let dPMul = BInt(dProduct) * BInt(N_COINS)
    
    let leverageVal = (leverageMul + dPMul) * BInt(initialD)

    let leverageSub = BInt(initialD) * BInt(leverage - 1)
    let nCoinsSum = BInt(dProduct) * BInt(N_COINS + 1)
    
    let rVal = leverageSub + nCoinsSum
    
    return UInt64(leverageVal / rVal)
}

/// Compute swap amount `y` in proportion to `x`
/// Solve for y:
/// y**2 + y * (sum' - (A*n**n - 1) * D / (A * n**n)) = D ** (n + 1) / (n ** (2 * n) * prod' * A)
/// y**2 + b*y = c
private func _computeOutputAmount(leverage: UInt64, newInputAmount: UInt64, d: UInt64) -> UInt64 {
    let c = BInt(d) ** Int(N_COINS + 1) / (BInt(newInputAmount) * BInt(N_COINS_SQUARED) * BInt(leverage))
    
    let b = BInt(newInputAmount) + (BInt(d) / BInt(leverage))
    
    var yPrevious: BInt
    var y = BInt(d)
    
    for _ in 0..<32 {
        yPrevious = y
        y = ((y ** 2) + c) / ((y * 2) + b - BInt(d))
        if y == yPrevious {
            break
        }
    }
    
    return UInt64(y)
}

private func computeInputAmount(
  outputAmount: UInt64,
  inputPoolAmount: UInt64,
  outputPoolAmount: UInt64,
  amp: UInt64
) -> UInt64 {
    let leverage = BInt(amp) * BInt(N_COINS)
    let newOutputPoolAmount = BInt(outputPoolAmount) - BInt(outputAmount)
    let d = computeD(
        leverage: UInt64(leverage),
        amountA: outputPoolAmount,
        amountB: inputPoolAmount
    )
    let newInputPoolAmount = _computeOutputAmount(
        leverage: UInt64(leverage),
        newInputAmount: UInt64(newOutputPoolAmount),
        d: d
    )
    let inputAmount = newInputPoolAmount - inputPoolAmount
    return inputAmount
}


// Take the derivative of the invariant function over x
private func computeBaseOutputAmount(
  inputAmount: UInt64,
  inputPoolAmount: UInt64,
  outputPoolAmount: UInt64,
  amp: UInt64
) -> UInt64 {
    let leverage = BInt(amp) * BInt(N_COINS)
    let invariant = computeD(leverage: UInt64(leverage), amountA: inputPoolAmount, amountB: outputPoolAmount)
    let a = BInt(amp) * 16
    let b = a
    let c = BInt(invariant) * 4 - (BInt(invariant) * BInt(amp) * 16)
    
    let numerator = (a * 2 * BInt(inputPoolAmount) + (b * BInt(outputPoolAmount)) + c)
        * BInt(outputPoolAmount)
    
    let denominator = (a * BInt(inputPoolAmount) + (b * 2 * BInt(outputPoolAmount) + c))
        * BInt(inputPoolAmount)
    
    return UInt64(BInt(inputAmount) * numerator / denominator)
}
