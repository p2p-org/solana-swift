//
//  OrcaSwap+Data.swift
//  
//
//  Created by Chung Tran on 13/10/2021.
//

import Foundation
import RxSwift
import RxAlamofire

protocol OrcaSwapAPIClient {
    var network: String {get}
    func getTokens() -> Single<OrcaSwap.Tokens>
    func getAquafarms() -> Single<OrcaSwap.Aquafarms>
    func getPools() -> Single<OrcaSwap.Pools>
    func getProgramID() -> Single<OrcaSwap.ProgramID>
}

extension OrcaSwap {
    struct APIClient: OrcaSwapAPIClient {
        let network: String
        private let cache = [String: [DataType: Decodable]]() // Network: [DataType: Decodable]
        
        func getTokens() -> Single<OrcaSwap.Tokens> {
            get(type: .tokens, network: network)
        }
        
        func getAquafarms() -> Single<OrcaSwap.Aquafarms> {
            get(type: .aquafarms, network: network)
        }
        
        func getPools() -> Single<OrcaSwap.Pools> {
            get(type: .pools, network: network)
        }
        
        func getProgramID() -> Single<OrcaSwap.ProgramID> {
            get(type: .programIds, network: network)
        }
        
        // MARK: - Helpers
        private enum DataType: String {
            case aquafarms, pools, programIds, tokens
        }

        private func get<T: Decodable>(type: DataType, network: String) -> Single<T> {
            // cache
            if let cached = cache[network]?[type] as? T{
                return .just(cached)
            }
            
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
}
