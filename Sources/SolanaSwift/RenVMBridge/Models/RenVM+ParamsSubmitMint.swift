//
//  RenVM+ParamsSubmitMint.swift
//  SolanaSwift
//
//  Created by Chung Tran on 13/09/2021.
//

import Foundation

extension RenVM {
    public struct ParamsSubmitMint: Encodable {
        let hash: String
        let selector: String
        let version: String
        let `in`: In
        
        struct In: Encodable {
            let t: TypeIn
            let v: MintTransactionInput
            
            struct TypeIn: Encodable {
                let `struct`: [[String: String]] = [
                    ["txid": "bytes"],
                    ["txindex": "u32"],
                    ["amount": "u256"],
                    ["payload": "bytes"],
                    ["phash": "bytes32"],
                    ["to": "string"],
                    ["nonce": "bytes32"],
                    ["nhash": "bytes32"],
                    ["gpubkey": "bytes"],
                    ["ghash": "bytes32"]
                ]
            }
        }
    }
}
