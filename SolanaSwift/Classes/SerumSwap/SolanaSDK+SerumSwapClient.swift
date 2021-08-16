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
    
    public func getMarketAddresses(usdxMint: PublicKey, baseMint: PublicKey) -> Single<[PublicKey]> {
        getTokensList()
            .map {list in
                list.filter { token in
                    if token.address != baseMint.base58EncodedString {return false}
                    if usdxMint == usdcMint {return token.extensions?.serumV3Usdc != nil}
                    if usdxMint == usdtMint {return token.extensions?.serumV3Usdt != nil}
                    return false
                }
            }
            .map {list in
                let list = list.reduce([PublicKey]()) { result, token in
                    var result = result
                    if usdxMint == usdcMint,
                       let string = token.extensions?.serumV3Usdc,
                       let address = try? PublicKey(string: string)
                    {
                        result.append(address)
                    }
                    if usdxMint == usdtMint,
                       let string = token.extensions?.serumV3Usdt,
                       let address = try? PublicKey(string: string)
                    {
                        result.append(address)
                    }
                    return result
                }
                
                guard list.count > 0 else {
                    throw SerumSwapError("Usd(x) quoted market not found")
                }
                
                return list
            }
    }
    
    
    public func getMarketAddress(usdxMint: PublicKey, baseMint: PublicKey) -> Single<PublicKey> {
        getMarketAddresses(usdxMint: usdxMint, baseMint: baseMint)
            .map {$0.first!}
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
