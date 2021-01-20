//
//  BytesEncodable.swift
//  SolanaSwift
//
//  Created by Chung Tran on 20/01/2021.
//

import Foundation
import BigInt

protocol BytesEncodable {
    var bytes: [UInt8] {get}
}

extension BigInt: BytesEncodable {
    var bytes: [UInt8] { serialize().bytes.reversed() }
}

extension BigUInt: BytesEncodable {
    var bytes: [UInt8] { serialize().bytes.reversed() }
}

extension UInt8: BytesEncodable {
    var bytes: [UInt8] { [self] }
}

extension UInt64: BytesEncodable {}

extension SolanaSDK.PublicKey: BytesEncodable {}

extension Data: BytesEncodable {}

extension Bool: BytesEncodable {
    var bytes: [UInt8] {self ? [UInt8(1)]: [UInt8(0)]}
}

extension Array: BytesEncodable where Element == BytesEncodable {
    var bytes: [UInt8] {reduce([], {$0 + $1.bytes})}
}

extension RawRepresentable where RawValue == UInt32 {
    var bytes: [UInt8] {rawValue.bytes}
}

extension RawRepresentable where RawValue == UInt8 {
    var bytes: [UInt8] {rawValue.bytes}
}
