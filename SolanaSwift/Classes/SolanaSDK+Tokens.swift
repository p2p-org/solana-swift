//
//  SolanaSDK+Tokens.swift
//  SolanaSwift
//
//  Created by Chung Tran on 26/01/2021.
//

import Foundation
import RxSwift

extension SolanaSDK {
    public func getTokensInfo(account: String? = nil) -> Single<[Token]> {
        getAllSPLTokens(account: account)
            .flatMap { tokens in
                var unfilledTokens = [Token]()
                
                // retrieve decimals if missing
                for token in tokens where token.decimals == nil {
                    unfilledTokens.append(token)
                }
                if unfilledTokens.count > 0 {
                    return Single<UInt8>.zip(
                        unfilledTokens.map {
                            return self.getAccountInfo(account: $0.mintAddress, decodedTo: Mint.self)
                                .map {$0.data.value?.decimals ?? 0}
                        }
                    )
                    .map {
                        var tokens = tokens
                        for i in 0..<unfilledTokens.count {
                            unfilledTokens[i].decimals = Int($0[i])
                            if let index = tokens.firstIndex(where: {$0.pubkey == unfilledTokens[i].pubkey})
                            {
                                tokens[index] = unfilledTokens[i]
                            }
                        }
                        return tokens
                    }
                }
                
                // if all decimals isn't missing
                return .just(tokens)
            }
    }
    
    func getAllSPLTokens(account: String? = nil) -> Single<[Token]> {
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
                $0.compactMap {
                    $0.account.data.value != nil ?
                        Token(accountInfo: $0.account.data.value!, pubkey: $0.pubkey, in: self.network)
                        : nil
                }
            }
    }
}
