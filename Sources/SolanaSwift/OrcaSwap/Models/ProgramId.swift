//
//  File.swift
//  
//
//  Created by Chung Tran on 13/10/2021.
//

import Foundation

extension OrcaSwap {
    struct ProgramID: Decodable {
        let serumTokenSwap, tokenSwapV2, tokenSwap, token: String
        let aquafarm: String
    }
}
