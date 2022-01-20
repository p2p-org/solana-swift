//
//  File.swift
//  
//
//  Created by Chung Tran on 13/10/2021.
//

import Foundation

public struct OrcaSwapError: Error {
    let description: String
    
    public static var notFound: Self {
        .init(description: "Not found")
    }
    
    public static var swapInfoMissing: Self {
        .init(description: "Swap is not available")
    }
    
    public static var accountBalanceNotFound: Self {
        .init(description: "Account balance is not found")
    }
    
    public static var unauthorized: Self {
        .init(description: "Unauthorized")
    }
    
    public static var couldNotEstimatedMinimumOutAmount: Self {
        .init(description: "Could not estimate minimum output amount")
    }
    
    // MARK: - Pools
    public static var invalidInputAmount: Self {
        .init(description: "Invalid input amount")
    }
    
    public static var invalidPool: Self {
        .init(description: "Invalid pool")
    }
    
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
    
    public static var intermediaryTokenAddressNotFound: Self {
        .init(description: "Intermediary token address not found")
    }
}
