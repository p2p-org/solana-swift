//
//  Bytes+Extensions.swift
//  SolanaSwift
//
//  Created by Chung Tran on 10/28/20.
//

import Foundation

public extension SolanaSDK {
    typealias Byte = UInt8
    typealias Bytes = [UInt8]
}

public extension SolanaSDK.Bytes {
    var decodedLength: Int {
        let len = 0
        var size = 0
        while true {
            guard let elem = self.first, len != (elem & 0x7f) << (size * 7) else {return 0}
            self.dropFirst()
            size += 1;
            if ((elem & 0x80) == 0) {
                break;
            }
        }
        return len
    }
}
