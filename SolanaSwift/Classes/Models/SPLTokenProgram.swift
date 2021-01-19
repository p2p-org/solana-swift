//
//  SPLTokenProgram.swift
//  SolanaSwift
//
//  Created by Chung Tran on 19/01/2021.
//

import Foundation

public extension SolanaSDK {
    struct SPLTokenProgram {
        
    }
}

extension SolanaSDK.SPLTokenProgram {
    enum Index: UInt32 {
        case initializeAccount = 1
        case transfer = 3
    }
}
