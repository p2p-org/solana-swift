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

public extension OrcaSwap {
    struct Pool: Decodable {
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
        
        var reversed: Pool {
            var reversedPool = self
            swap(&reversedPool.tokenAccountA, &reversedPool.tokenAccountB)
            swap(&reversedPool.tokenAName, &reversedPool.tokenBName)
            swap(&reversedPool.tokenABalance, &reversedPool.tokenBBalance)
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
            case "Stable":
                guard let amp = amp else {throw OrcaSwapError.ampDoesNotExistInPoolConfig}
                return computeOutputAmount(
                    inputAmount: inputAmountLessFee,
                    inputPoolAmount: poolInputAmount,
                    outputPoolAmount: poolOutputAmount,
                    amp: amp
                )
            case "ConstantProduct":
                let invariant = BInt(poolInputAmount) * BInt(poolOutputAmount)
                let newPoolOutputAmount = ceilingDivision(invariant, BInt(poolInputAmount + inputAmountLessFee)).quotient
                return poolOutputAmount - newPoolOutputAmount
            default:
                return nil
            }
        }
        
        // MARK: - Helpers
        private func getFee(_ inputAmount: UInt64) throws -> UInt64 {
            guard curveType == "Stable" || curveType == "ConstantProduct" else {throw OrcaSwapError.unknown}
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
                // reverse pool if needed
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
        forPath path: String, // Ex. BTC/SOL[aquafarm]
        solanaClient: OrcaSwapSolanaClient
    ) -> Single<OrcaSwap.Pool?> {
        guard var pool = self[path] else {return .just(nil)}
        
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
    ) throws -> UInt64? {
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
func calculateStep(
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
