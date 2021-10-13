//
//  OrcaSwap+Data.swift
//  
//
//  Created by Chung Tran on 13/10/2021.
//

import Foundation
import RxSwift
import RxAlamofire

extension OrcaSwap {
    static func getTokens(network: String) -> Single<Tokens> {
        get(type: .tokens, network: network)
    }
    
    // MARK: - Helpers
    private enum DataType: String {
        case aquafarms, pools, programIds, tokens
    }
    
    private static func get<T: Decodable>(type: DataType, network: String) -> Single<T> {
        // hack: network
        var network = network
        if network == "mainnet-beta" {network = "mainnet"}
        
        // prepare url
        let endpoint = "https://raw.githubusercontent.com/p2p-org/p2p-wallet-web/develop/src/app/contexts/swap/orca-commons/data/json"
        let url = [endpoint, type.rawValue, "\(network).json"].joined(separator: "/")
        
        // get
        return request(.get, url)
            .validate()
            .responseData()
            .take(1)
            .asSingle()
            .map {(response, data) -> T in
                let list = try JSONDecoder().decode(T.self, from: data)
                return list
            }
    }
}
