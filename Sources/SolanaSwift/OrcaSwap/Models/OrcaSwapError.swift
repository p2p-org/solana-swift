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
        .init(description: "SwapInfoMissing")
    }
}
