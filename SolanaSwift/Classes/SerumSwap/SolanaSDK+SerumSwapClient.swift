//
//  SolanaSDK+SerumSwapClient.swift
//  SolanaSwift
//
//  Created by Chung Tran on 09/08/2021.
//

import Foundation
import RxSwift

extension SolanaSDK: SerumSwapAPIClient {
    public func simulateTransaction(transaction: String) -> Single<TransactionStatus> {
        simulateTransaction(transaction: transaction, configs: .init(encoding: "base64")!)
    }
    
    public func getMinimumBalanceForRentExemption(span: UInt64) -> Single<UInt64> {
        self.getMinimumBalanceForRentExemption(dataLength: span)
    }
    
    public func getMarketAddressIfNeeded(usdxMint: PublicKey, baseMint: PublicKey) -> Single<PublicKey> {
        getMarketAddress(usdxMint: usdxMint, baseMint: baseMint)
            .flatMap {[weak self] marketAddress -> Single<PublicKey> in
                guard let self = self else {throw SerumSwapError.unknown}
                
                guard let owner = self.getNativeWalletAddress()
                else {throw SerumSwapError.unauthorized}
                
                return SerumSwap.OpenOrders.findForMarketAndOwner(
                    client: self,
                    marketAddress: marketAddress,
                    ownerAddress: owner,
                    programId: dexPID
                )
                    .map {markets -> PublicKey in
                        if markets.first != nil {
                            throw SerumSwapError("Open orders account already exists")
                        }
                        return marketAddress
                    }
            }
    }
    
    public func getMarketAddress(usdxMint: PublicKey, baseMint: PublicKey) -> Single<PublicKey> {
        getTokensList()
            .map {list in
                list.first { token in
                    if token.address != baseMint.base58EncodedString {return false}
                    if usdxMint == usdcMint {return token.extensions?.serumV3Usdc == nil}
                    if usdxMint == usdtMint {return token.extensions?.serumV3Usdt == nil}
                    return false
                }
            }
            .map {token -> String? in
                guard let extensions = token?.extensions else {
                    throw SerumSwapError("Usd(x) quoted market not found")
                }
                if usdxMint == usdcMint {return extensions.serumV3Usdc}
                if usdxMint == usdtMint {return extensions.serumV3Usdt}
                throw SerumSwapError("Usd(x) quoted market not found")
            }
            .map {string -> PublicKey in
                guard let string = string else {
                    throw SerumSwapError("Usd(x) quoted market not found")
                }
                return try PublicKey(string: string)
            }
    }
    
    public func usdcPathExists(fromMint: PublicKey, toMint: PublicKey) -> Single<Bool> {
        getTokensList()
            .map { tokens in
                tokens.contains {$0.address == fromMint.base58EncodedString && $0.extensions?.serumV3Usdc != nil}
                &&
                tokens.contains {$0.address == toMint.base58EncodedString && $0.extensions?.serumV3Usdc != nil}
            }
    }
}

extension SolanaSDK: SerumSwapAccountProvider {
    public func getNativeWalletAddress() -> PublicKey? {
        accountStorage.account?.publicKey
    }
}
