//
//  ResponseQueryTxMint.swift
//  SolanaSwift
//
//  Created by Chung Tran on 13/09/2021.
//

import Foundation

extension RenVM {
    public struct ResponseQueryTxMint: Decodable {
        let tx: Tx
        let txStatus: String
        
        var valueOut: Tx.Out.ValueOut {
            tx.out.v
        }
        
        var valueIn: Tx.In.ValueIn {
            tx.in.v
        }
        
        struct Tx: Decodable {
            let hash: String
            let version: String
            let selector: String
            let `in`: In
            let out: Out
            
            struct In: Decodable {
                let v: ValueIn
                
                struct ValueIn: Decodable {
                    let amount: String
                    let ghash: String
                    let gpubkey: String
                    let nhash: String
                    let nonce: String
                    let payload: String
                    let phash: String
                    let to: String
                    let txid: String
                    let txindex: String
                }
            }
            
            struct Out: Decodable {
                let t: TypeOut
                let v: ValueOut
                
                struct TypeOut: Decodable {
                    let `struct`: [OutStructType]?
                    struct OutStructType: Decodable {
                        let hash: String?
                        let amount: String?
                        let sighash: String?
                        let sig: String?
                        let txid: String?
                        let txindex: String?
                    }
                }
                
                struct ValueOut: Decodable {
                    let amount: String?
                    let hash: String?
                    let sig: String?
                    let sighash: String?
                    let txid: String?
                    let txindex: String?
                }
            }
        }
        
    }
}
