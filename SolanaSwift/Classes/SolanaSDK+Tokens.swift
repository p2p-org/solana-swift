//
//  SolanaSDK+Tokens.swift
//  SolanaSwift
//
//  Created by Chung Tran on 26/01/2021.
//

import Foundation
import RxSwift

extension SolanaSDK {
    public func getTokenWallets(account: String? = nil) -> Single<[Wallet]> {
        guard let account = account ?? accountStorage.account?.publicKey.base58EncodedString else {
            return .error(Error.unauthorized)
        }
        let memcmp = EncodableWrapper(
            wrapped:
                ["offset": EncodableWrapper(wrapped: 32),
                 "bytes": EncodableWrapper(wrapped: account)]
        )
        let configs = RequestConfiguration(commitment: "recent", encoding: "base64", dataSlice: nil, filters: [
            ["memcmp": memcmp],
            ["dataSize": .init(wrapped: 165)]
        ])
        return getProgramAccounts(
            publicKey: PublicKey.tokenProgramId.base58EncodedString,
            configs: configs,
            decodedTo: AccountInfo.self
        )
            .map {
                $0.compactMap {$0.account.data.value != nil ? $0: nil}
            }
            .map {$0.map {($0.pubkey, $0.account.data.value!)}}
            .flatMap { list -> Single<[Wallet]> in
                var knownWallets = [Wallet]()
                var unknownAccounts = [(String, AccountInfo)]()
                
                for item in list {
                    let pubkey = item.0
                    let accountInfo = item.1
                    
                    let mintAddress = accountInfo.mint.base58EncodedString
                    // known token
                    if let token = self.supportedTokens.first(where: {$0.address == mintAddress})
                    {
                        knownWallets.append(
                            Wallet(
                                pubkey: pubkey,
                                lamports: accountInfo.lamports,
                                token: token
                            )
                        )
                    }
                    
                    // unknown token
                    else {
                        unknownAccounts.append(item)
                    }
                    
                }
                
                return self.getMultipleMintDatas(
                    mintAddresses: unknownAccounts.map{$0.1.mint}
                )
                    .map {mintDatas -> [Wallet] in
                        guard mintDatas.count == unknownAccounts.count
                        else {throw Error.unknown}
                        var wallets = [Wallet]()
                        for (index, item) in mintDatas.enumerated() {
                            wallets.append(
                                Wallet(
                                    pubkey: unknownAccounts[index].0,
                                    lamports: unknownAccounts[index].1.lamports,
                                    token: .unsupported(
                                        mint: unknownAccounts[index].1.mint.base58EncodedString,
                                        decimals: item.value.decimals
                                    )
                                )
                            )
                        }
                        return wallets
                    }
                    .catchAndReturn(unknownAccounts.map {
                        Wallet(pubkey: $0.0, lamports: $0.1.lamports, token: .unsupported(mint: $0.1.mint.base58EncodedString))
                    })
                    .map {knownWallets + $0}
            }
    }
    
    public func checkAccountValidation(account: String) -> Single<Bool> {
        getAccountInfo(account: account, decodedTo: EmptyInfo.self)
            .map {_ in true}
            .catch {error in
                if let error = error as? Error, error == .other("Could not retrieve account info")
                {
                    return .just(false)
                }
                throw error
            }
    }
}
