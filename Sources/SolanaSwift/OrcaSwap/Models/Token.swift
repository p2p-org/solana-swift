//
//  OrcaSwap+Token.swift
//  
//
//  Created by Chung Tran on 13/10/2021.
//

import Foundation

public extension OrcaSwap {
    struct Token: Decodable {
        let mint, name: String
        let decimals: Int
        let fetchPrice, poolToken: Bool?
        let wrapper: String?
    }

    typealias Tokens = [String: Token] // [poolId: string]: TokenJSON;
    
//    struct TokenConfig: Decodable {
//        let token: Token
//        let mint: SolanaSDK.PublicKey
//    }
//    
//    typealias TokenConfigs = [String: TokenConfig] // [poolId: string]: TokenConfig;
}
