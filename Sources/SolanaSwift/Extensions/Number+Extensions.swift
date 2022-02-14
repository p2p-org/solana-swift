//
//  Number+Extensions.swift
//  SolanaSwift
//
//  Created by Chung Tran on 11/6/20.
//

import Foundation

extension UInt32 {
    public var bytes: [UInt8] {
        var littleEndian = self.littleEndian
        return withUnsafeBytes(of: &littleEndian) { Array($0) }
    }
}

extension UInt64 {
    public var bytes: [UInt8] {
        var littleEndian = self.littleEndian
        return withUnsafeBytes(of: &littleEndian) { Array($0) }
    }
    
    public func convertToBalance(decimals: Int?) -> Double {
        guard let decimals = decimals else {return 0}
        return convertToBalance(decimals: UInt8(decimals))
    }
    
    public func convertToBalance(decimals: UInt8?) -> Double {
        guard let decimals = decimals else {return 0}
        return (Double(self) * pow(10, -Double(decimals))).rounded(toPlaces: decimals)
    }
}

extension Double {
    public func toLamport(decimals: Int) -> UInt64 {
        UInt64((self * pow(10, Double(decimals))).rounded())
    }
    public func toLamport(decimals: UInt8) -> UInt64 {
        toLamport(decimals: Int(decimals))
    }
    
    /// Rounds the double to decimal places value
    func rounded(toPlaces places: Int) -> Double {
        rounded(toPlaces: UInt8(places))
    }
    func rounded(toPlaces places: UInt8) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
