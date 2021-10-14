//
//  File.swift
//  
//
//  Created by Chung Tran on 13/10/2021.
//

import Foundation

public struct OrcaSwapError: Error {
    let description: String
    
    public static var swapInfoMissing: Self {
        .init(description: "Swap is not available")
    }
    
    public static var accountBalanceNotFound: Self {
        .init(description: "Account balance is not found")
    }
    
    // MARK: - Pools
    public static var ampDoesNotExistInPoolConfig: Self {
        .init(description: "amp does not exist in poolConfig")
    }
    
    public static var estimatedAmountIsTooHigh: Self {
        .init(description: "Estimated amount is too high")
    }
    
    // MARK: - Unknown
    public static var unknown: Self {
        .init(description: "Unknown error")
    }
}
