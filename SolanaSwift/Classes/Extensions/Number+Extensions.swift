//
//  Number+Extensions.swift
//  SolanaSwift
//
//  Created by Chung Tran on 11/6/20.
//

import Foundation

extension UInt32 {
    var bytes: [UInt8] {
        var littleEndian = self.littleEndian
        return withUnsafeBytes(of: &littleEndian) { Array($0) }
    }
}

extension UInt64 {
    var bytes: [UInt8] {
        var littleEndian = self.littleEndian
        return withUnsafeBytes(of: &littleEndian) { Array($0) }
    }
    
    public func convertToBalance(decimals: Int) -> Double {
        Double(self) * pow(10, -Double(decimals))
    }
}

extension Double {
    public func toLamport(decimals: Int) -> UInt64 {
        UInt64((self * pow(10, Double(decimals))).rounded())
    }
}
