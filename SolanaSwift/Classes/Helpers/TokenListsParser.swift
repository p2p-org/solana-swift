//
//  TokenListsParser.swift
//  Alamofire
//
//  Created by Chung Tran on 22/04/2021.
//

import Foundation
import RxSwift
import RxAlamofire

public extension SolanaSDK {
    class TokensListParser {
        public init() {}
        public func parse(network: String) -> Single<[Token]> {
            RxAlamofire.request(.get, "https://raw.githubusercontent.com/solana-labs/token-list/main/src/tokens/solana.tokenlist.json")
                .validate()
                .responseData()
                .take(1)
                .asSingle()
                .map {(response, data) -> TokensList in
                    let list = try JSONDecoder().decode(TokensList.self, from: data)
                    return list
                }
                .catch { _ in
                    // get json file
                    let bundle = Bundle(for: TokensListParser.self)
                    let path = bundle.path(forResource: network + ".tokens", ofType: "json")
                    let jsonData = try Data(contentsOf: URL(fileURLWithPath: path!))
                    
                    return .just(try JSONDecoder().decode(TokensList.self, from: jsonData))
                }
                .map {list -> TokensList in
                    var list = list
                    // map tags
                    list.tokens = list.tokens.map {
                        var item = $0
                        item.tags = (item._tags ?? []).map {
                            list.tags[$0] ?? TokenTag(name: $0, description: $0)
                        }
                        return item
                    }
                    
                    return list
                }
                .map {$0.tokens}
        }
    }
}
