//
//  NaclLowLevel.swift
//  SolanaSwift
//
//  Created by Chung Tran on 27/04/2021.
//

import Foundation

struct NaclLowLevel {
    static func gf(_ initialData: [Float64]? = nil) -> [Float64] {
        var r = [Float64](repeating: 0, count: 16)
        if let initialData = initialData {
            for (index, value) in initialData.enumerated() {
                r[index] = value
            }
        }
        return r
    }
    
    static func set25519(r: inout [Float64], a: [Float64]) {
        for i in 0..<16 {
            if a.count > i {
                r[i] = a[i]
            } else {
                r[i] = 0
            }
        }
    }
}
