//
//  SolanaSDK+Tokens.swift
//  SolanaSwift
//
//  Created by Chung Tran on 26/01/2021.
//

import Foundation
import RxSwift

extension SolanaSDK {
    public func getTokensList() -> Single<[Token]> {
        let getCacheTokensRequest = Single<[Token]?>
            .create { [weak self] observer in
                if let cache = self?.supportedTokensCache {
                    observer(.success(cache))
                } else {
                    observer(.success(nil))
                }
                return Disposables.create()
            }
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
        
        return getCacheTokensRequest
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .flatMap { [weak self] tokens in
                guard let self = self else {return .just([])}
                if let tokens = tokens {
                    return .just(tokens)
                }
                let parser = TokensListParser()
                return parser.parse(network: self.endpoint.network.cluster)
                    .do(onSuccess: {[weak self] in self?.supportedTokensCache = $0})
            }
    }
    
    public func getTokenWallets(account: String? = nil, log: Bool = true) -> Single<[Wallet]> {
        guard let account = account ?? accountStorage.account?.publicKey.base58EncodedString else {
            return .error(Error.unauthorized)
        }
        
        return Single.zip(
            getTokenAccountsByOwner(
                pubkey: account,
                params: .init(mint: nil, programId: PublicKey.tokenProgramId.base58EncodedString),
                configs: .init(encoding: "base64"),
                log: log
            ),
            getTokensList()
        )
            .flatMap { list, supportedTokens -> Single<[Wallet]> in
                var knownWallets = [Wallet]()
                var unknownAccounts = [(String, AccountInfo)]()
                
                for item in list {
                    let pubkey = item.pubkey
                    let accountInfo = item.account.data
                    
                    let mintAddress = accountInfo.mint.base58EncodedString
                    // known token
                    if let token = supportedTokens.first(where: {$0.address == mintAddress})
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
                        unknownAccounts.append((item.pubkey, item.account.data))
                    }
                    
                }
                
                return self.getMultipleMintDatas(
                    mintAddresses: unknownAccounts.map{$0.1.mint.base58EncodedString},
                    log: log
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
                if error.isEqualTo(.couldNotRetrieveAccountInfo) {
                    return .just(false)
                }
                throw error
            }
    }
}
