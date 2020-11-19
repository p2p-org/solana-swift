//
//  Bytes+Extensions.swift
//  SolanaSwift
//
//  Created by Chung Tran on 11/12/20.
//

import Foundation

extension Array where Element == UInt8 {
    func toUInt64() -> UInt64? {
        let data = Data(self)
        return UInt64(littleEndian: data.withUnsafeBytes { $0.pointee })
    }
    
    func toInt() -> Int {
        var value : Int = 0
        for byte in self {
            value = value << 8
            value = value | Int(byte)
        }
        return value
    }
}
