//
//  SolanaSDK+Tokens.swift
//  SolanaSwift
//
//  Created by Chung Tran on 26/01/2021.
//

import Foundation
import RxSwift

extension SolanaSDK {
    public func getTokenWallets() -> Single<[Wallet]> {
        getCurrentAccount()
            .flatMap {account in
                let memcmp = EncodableWrapper(
                    wrapped:
                        ["offset": EncodableWrapper(wrapped: 32),
                         "bytes": EncodableWrapper(wrapped: account)]
                )
                let configs = RequestConfiguration(commitment: "recent", encoding: "base64", dataSlice: nil, filters: [
                    ["memcmp": memcmp],
                    ["dataSize": .init(wrapped: 165)]
                ])
                return self.getProgramAccounts(
                    publicKey: PublicKey.tokenProgramId.base58EncodedString,
                    configs: configs,
                    decodedTo: AccountInfo.self
                )
                    .map {
                        $0.compactMap {$0.account.data.value != nil ? $0: nil}
                    }
                    .map {$0.map {($0.pubkey, $0.account.data.value!)}}
                    .map {
                        $0.map { (pubkey, accountInfo) in
                            let mintAddress = accountInfo.mint.base58EncodedString
                            let token = self.supportedTokens.first(where: {$0.address == mintAddress}) ?? .unsupported(mint: mintAddress)
                            
                            return Wallet(
                                pubkey: pubkey,
                                lamports: accountInfo.lamports,
                                token: token,
                                liquidity: false
                            )
                        }
                    }
            }
    }
}
