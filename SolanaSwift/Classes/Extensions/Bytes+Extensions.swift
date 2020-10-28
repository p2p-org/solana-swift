//
//  Bytes+Extensions.swift
//  SolanaSwift
//
//  Created by Chung Tran on 10/28/20.
//

import Foundation

public typealias Byte = UInt8
public typealias Bytes = [UInt8]

public extension Bytes {
    var decodedLength: Int {
        var len = 0
        var size = 0
        var bytes = self
        while true {
            guard let elem = bytes.first else {break}
            bytes = Bytes(bytes.dropFirst())
            len = len | (Int(elem) & 0x7f) << (size * 7)
            size += 1;
            if (elem & 0x80) == 0 {
                break
            }
        }
        return len
    }
}
