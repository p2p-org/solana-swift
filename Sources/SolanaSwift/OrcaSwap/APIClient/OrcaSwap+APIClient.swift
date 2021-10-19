//
//  OrcaSwap+Data.swift
//  
//
//  Created by Chung Tran on 13/10/2021.
//

import Foundation
import RxSwift
import RxAlamofire

public protocol OrcaSwapAPIClient {
    var network: String {get}
    func get<T: Decodable>(type: String) -> Single<T>
}

public extension OrcaSwapAPIClient {
    func getTokens() -> Single<OrcaSwap.Tokens> {
        get(type: "tokens")
    }
    
    func getAquafarms() -> Single<OrcaSwap.Aquafarms> {
        get(type: "aquafarms")
    }
    
    func getPools() -> Single<OrcaSwap.Pools> {
        get(type: "pools")
    }
    
    func getProgramID() -> Single<OrcaSwap.ProgramID> {
        get(type: "programIds")
    }
}

extension OrcaSwap {
    public struct APIClient: OrcaSwapAPIClient {
        public init(network: String) {
            self.network = network
        }
        
        public let network: String
        private let cache = [String: [String: Decodable]]() // Network: [DataType: Decodable]
        
        // MARK: - Helpers
        public func get<T: Decodable>(type: String) -> Single<T> {
            // cache
            if let cached = cache[network]?[type] as? T{
                return .just(cached)
            }
            
            // hack: network
            var network = network
            if network == "mainnet-beta" {network = "mainnet"}
            
            // prepare url
            let endpoint = "https://raw.githubusercontent.com/p2p-org/p2p-wallet-web/develop/src/app/contexts/swap/orca-commons/data/json"
            let url = [endpoint, type, "\(network).json"].joined(separator: "/")
            
            // get
            return request(.get, url)
                .observe(on: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
                .validate()
                .responseData()
                .take(1)
                .asSingle()
                .observe(on: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
                .map {(response, data) -> T in
                    let list = try JSONDecoder().decode(T.self, from: data)
                    return list
                }
        }
    }
}
