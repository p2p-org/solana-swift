//
//  ResponseQueryBlockState.swift
//  SolanaSwift
//
//  Created by Chung Tran on 13/09/2021.
//

import Foundation

extension RenVM {
    public struct ResponseQueryBlockState: Decodable {
        let state: State
        var shards: [Shard] {
            state.v.btc.shards
        }
        var publicKey: String? {
            shards.first?.pubKey
        }
        
        struct State: Decodable {
            let v: Values
        }
        
        struct Values: Decodable {
            let btc: Btc
        }
        
        struct Btc: Decodable {
            let fees: Fees
            let gasCap: String
            let gasLimit: String
            let gasPrice: String
            let latestHeight: String
            let minimumAmount: String
            let shards: [Shard]
        }
        
        struct Fees: Decodable {
            let chains: [Chain]
        }
        
        struct Chain: Decodable {
            let burnFee: String
            let chain: String
            let mintFee: String
        }
        
        struct Shard: Decodable {
            let pubKey: String
            let shard: String
            let state: ShardState
        }
        
        struct ShardState: Decodable {
            let outpoint: Outpoint
            let pubKeyScript: String
            let value: String
        }
        
        struct Outpoint: Decodable {
            let hash: String
            let index: String
        }
    }
}
