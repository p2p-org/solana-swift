//
//  SolanaSDK+Pool.swift
//  SolanaSwift
//
//  Created by Chung Tran on 26/01/2021.
//

import Foundation
import RxSwift

private var mintDatasCache = [SolanaSDK.Mint]()

extension SolanaSDK {
    struct ParsedSwapInfo: Codable {
        let address: String
        let info: TokenSwapInfo
        var mintDatas: ParsedSwapInfoMintDatas?
    }
    
    struct ParsedSwapInfoMintDatas: Codable {
        var mintA: Mint?
        var mintB: Mint?
        var tokenPool: Mint?
    }
    
    public func getSwapPools() -> Single<[Pool]> {
        getPools(swapProgramId: PublicKey.orcaSwapId().base58EncodedString)
            .map {
                $0.filter {
                    $0.tokenABalance?.amountInUInt64 != 0 &&
                        $0.tokenBBalance?.amountInUInt64 != 0
                }
            }
    }
    
    func getPools(swapProgramId: String) -> Single<[Pool]> {
        getProgramAccounts(publicKey: swapProgramId, decodedTo: TokenSwapInfo.self)
            .flatMap { [weak self] programs -> Single<[ParsedSwapInfo]> in
                guard let self = self else {throw Error.unknown}
                
                // get parsed swap info
                let result = programs.accounts.compactMap {program -> ParsedSwapInfo? in
                    let swapData = program.account.data
                    guard swapData.mintA.base58EncodedString != "11111111111111111111111111111111",
                          swapData.mintB.base58EncodedString != "11111111111111111111111111111111",
                          swapData.tokenPool.base58EncodedString != "11111111111111111111111111111111"
                    else {return nil}
                    return ParsedSwapInfo(address: program.pubkey, info: swapData)
                }
                
                // get all mint addresses
                let mintAddresses = result.reduce([PublicKey](), {
                    var result = $0
                    if !result.contains($1.info.mintA) {
                        result.append($1.info.mintA)
                    }
                    if !result.contains($1.info.mintB) {
                        result.append($1.info.mintB)
                    }
                    if !result.contains($1.info.tokenPool) {
                        result.append($1.info.tokenPool)
                    }
                    return result
                })
                
                // split array to form multiple requests (max address per request is 100)
                let requestChunks = mintAddresses.chunked(into: 100)
                    .map {self.getMultipleMintDatas(mintAddresses: $0.map {$0.base58EncodedString})}
                
                return Single.zip(requestChunks)
                    .map {results -> [String: Mint] in
                        var joinedResult = [String: Mint]()
                        for result in results {
                            for (key, value) in result {
                                joinedResult[key] = value
                            }
                        }
                        return joinedResult
                    }
                    .map {mintDatas in
                        var parsedInfo = result
                        for i in 0..<parsedInfo.count {
                            let swapInfo = parsedInfo[i].info
                            parsedInfo[i].mintDatas = .init(
                                mintA: mintDatas[swapInfo.mintA.base58EncodedString],
                                mintB: mintDatas[swapInfo.mintB.base58EncodedString],
                                tokenPool: mintDatas[swapInfo.tokenPool.base58EncodedString]
                            )
                        }
                        return parsedInfo
                    }
                    
            }
//            .do(onSuccess: {parsedInfo in
//                Logger.log(message: String(data: try JSONEncoder().encode(parsedInfo), encoding: .utf8)!, event: .response)
//
//            })
            .map { [weak self] parsedSwapInfos in
                guard let self = self else {throw Error.unknown}
                return parsedSwapInfos.map {self.getPool(parsedSwapInfo: $0)}
                    .compactMap {$0}
            }
    }
    
    private func getPool(parsedSwapInfo: ParsedSwapInfo) -> Pool? {
        guard let address = try? PublicKey(string: parsedSwapInfo.address),
              let tokenAInfo = parsedSwapInfo.mintDatas?.mintA,
              let tokenBInfo = parsedSwapInfo.mintDatas?.mintB,
              let poolTokenMintInfo = parsedSwapInfo.mintDatas?.tokenPool
        else {return nil}
        return Pool(
            address: address,
            tokenAInfo: tokenAInfo,
            tokenBInfo: tokenBInfo,
            poolTokenMint: poolTokenMintInfo,
            swapData: parsedSwapInfo.info
        )
    }
    
    public func getPoolWithTokenBalances(pool: Pool) -> Single<Pool> {
        let requestABalance: Single<TokenAccountBalance>
        let requestBBalance: Single<TokenAccountBalance>
        
        if let tokenABalance = pool.tokenABalance {
            requestABalance = .just(tokenABalance)
        } else {
            requestABalance = getTokenAccountBalance(pubkey: pool.swapData.tokenAccountA.base58EncodedString)
        }
        
        if let tokenBBalance = pool.tokenBBalance {
            requestBBalance = .just(tokenBBalance)
        } else {
            requestBBalance = getTokenAccountBalance(pubkey: pool.swapData.tokenAccountB.base58EncodedString)
        }
        
        return Single.zip(requestABalance, requestBBalance)
            .map { (tokenABalance, tokenBBalance) in
                var pool = pool
                pool.tokenABalance = tokenABalance
                pool.tokenBBalance = tokenBBalance
                return pool
            }
    }
}

private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
