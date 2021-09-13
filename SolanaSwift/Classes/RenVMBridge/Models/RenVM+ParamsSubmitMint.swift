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
//                @Json(name = "struct")
//                public List<Object> struct = Arrays.asList(Map.of("txid", "bytes"), Map.of("txindex", "u32"),
//                        Map.of("amount", "u256"), Map.of("payload", "bytes"), Map.of("phash", "bytes32"),
//                        Map.of("to", "string"), Map.of("nonce", "bytes32"), Map.of("nhash", "bytes32"),
//                        Map.of("gpubkey", "bytes"), Map.of("ghash", "bytes32"));
            }
        }
    }
}
