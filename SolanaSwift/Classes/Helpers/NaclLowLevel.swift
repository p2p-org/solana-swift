//
//  NaclLowLevel.swift
//  SolanaSwift
//
//  Created by Chung Tran on 27/04/2021.
//

import Foundation

struct NaclLowLevel {
    static func gf(_ initialData: [Double]? = nil) -> [Double] {
        var r = [Double](repeating: 0, count: 16)
        if let initialData = initialData {
            for (index, value) in initialData.enumerated() {
                if index >= 16 {break}
                r[index] = value
            }
        }
        return r
    }
    
    static func set25519(r: inout [Double], a: [Double]) {
        for i in 0..<16 {
            if a.count > i {
                r[i] = a[i]
            } else {
                r[i] = 0
            }
        }
    }
    
    static func unpack25519(o: inout [Double], n: [Double]) {
        for i in 0..<16 {
            o[i] = Double(BInt(n[2*i+1]) << 8)
        }
        o[15] &= 0x7fff
    }
}
