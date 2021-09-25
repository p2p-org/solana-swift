//
//  SerumSwap+SwapMarkets.swift
//  SolanaSwift
//
//  Created by Chung Tran on 17/08/2021.
//

import Foundation
import RxSwift

extension SerumSwap {
    struct SwapMarkets {
        let tokenListContainer: SerumSwapTokenListContainer
        
        /// Returns the `usdxMint` quoted market address.
        public func getMarketAddress(
            usdxMint: PublicKey,
            baseMint: PublicKey
        ) -> Single<PublicKey?> {
            tokenListContainer.getTokensList()
                .map {list in
                    list.first { token in
                        if token.address != baseMint.base58EncodedString {return false}
                        if usdxMint == .usdcMint {return token.extensions?.serumV3Usdc != nil}
                        if usdxMint == .usdtMint {return token.extensions?.serumV3Usdt != nil}
                        return false
                    }
                }
                .map {token -> PublicKey? in
                    if usdxMint == .usdcMint {return try? PublicKey(string: token?.extensions?.serumV3Usdc)}
                    if usdxMint == .usdtMint {return try? PublicKey(string: token?.extensions?.serumV3Usdt)}
                    return nil
                }
        }
        
        public func usdcPathExists(
            fromMint: PublicKey,
            toMint: PublicKey
        ) -> Single<Bool> {
            tokenListContainer.getTokensList()
                .map {list in
                    list.contains(where: {$0.address == fromMint.base58EncodedString && $0.extensions?.serumV3Usdc != nil}) ||
                        list.contains(where: {$0.address == toMint.base58EncodedString && $0.extensions?.serumV3Usdc != nil})
                }
        }
        
        public func route(
            fromMint: PublicKey,
            toMint: PublicKey
        ) -> Single<[PublicKey]?> {
            if fromMint == .usdcMint || fromMint == .usdtMint {
                return getMarketAddress(usdxMint: fromMint, baseMint: toMint)
                    .map {$0 == nil ? nil: [$0!]}
            }
            if toMint == .usdcMint || toMint == .usdtMint {
                return getMarketAddress(usdxMint: toMint, baseMint: fromMint)
                    .map {$0 == nil ? nil: [$0!]}
            }
            return getMarketPairs(usdxMint: .usdcMint, fromMint: fromMint, toMint: toMint)
                .flatMap {pairs in
                    guard let pairs = pairs else {
                        return getMarketPairs(usdxMint: .usdtMint, fromMint: fromMint, toMint: toMint)
                    }
                    return .just(pairs)
                }
        }
        
        // MARK: - helper
        private func getMarketPairs(
            usdxMint: PublicKey,
            fromMint: PublicKey,
            toMint: PublicKey
        ) -> Single<[PublicKey]?> {
            Single.zip(
                getMarketAddress(usdxMint: usdxMint, baseMint: fromMint),
                getMarketAddress(usdxMint: usdxMint, baseMint: toMint)
            )
            .map { fromMarket, toMarket in
                if let fromMarket = fromMarket,
                   let toMarket = toMarket
                {
                    return [fromMarket, toMarket]
                }
                return nil
            }
        }
    }
}
