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
        
        func publicKey(mintTokenSymbol: String) -> String? {
            if mintTokenSymbol == State.V.CodingKeys.btc.rawValue {
                return state.v.btc.shards.first?.pubKey
            }
            return nil
        }
        
        struct State: Decodable {
            let t: T
            let v: V
            struct T: Decodable {
                
            }
            
            struct V: Decodable {
                let btc: BTCValue
    //            let bch, btc, dgb, doge: StructBCH?
    //            let fil, luna: StructFIL?
    //            let system: StructSystem?
    //            let zec: StructBCH?

                enum CodingKeys: String, CodingKey {
                    case btc = "BTC"
                }
                
                struct BTCValue: Decodable {
                    let fees: Fees
                    let gasCap: String
                    let gasLimit: String
                    let gasPrice: String
                    let latestHeight: String
                    let minimumAmount: String
                    let shards: [Shard]
                }
            }
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
