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
        getPools(swapProgramId: endpoint.network.swapProgramId.base58EncodedString)
            .map {
                $0.filter {
                    $0.tokenABalance?.amountInUInt64 != 0 &&
                        $0.tokenBBalance?.amountInUInt64 != 0
                }
            }
    }
    
    func getPools(swapProgramId: String) -> Single<[Pool]> {
        getProgramAccounts(publicKey: swapProgramId, decodedTo: TokenSwapInfo.self)
            .flatMap { programs -> Single<[ParsedSwapInfo]> in
                
                // get parsed swap info
                let result = programs.compactMap {program -> ParsedSwapInfo? in
                    guard let swapData = program.account.data.value else {
                        return nil
                    }
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
                
                return self.getMultipleMintDatas(mintAddresses: mintAddresses)
                    .map {mintDatas in
                        var parsedInfo = result
                        for i in 0..<parsedInfo.count {
                            let swapInfo = parsedInfo[i].info
                            parsedInfo[i].mintDatas = .init(
                                mintA: mintDatas[swapInfo.mintA],
                                mintB: mintDatas[swapInfo.mintB],
                                tokenPool: mintDatas[swapInfo.tokenPool]
                            )
                        }
                        return parsedInfo
                    }
                    
            }
//            .do(onSuccess: {parsedInfo in
//                Logger.log(message: String(data: try JSONEncoder().encode(parsedInfo), encoding: .utf8)!, event: .response)
//
//            })
            .map { parsedSwapInfos in
                parsedSwapInfos.map {self.getPool(parsedSwapInfo: $0)}
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
}
