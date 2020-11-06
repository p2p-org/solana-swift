//
//  Array+Extensions.swift
//  SolanaSwift
//
//  Created by Chung Tran on 11/6/20.
//

import Foundation

extension Array {
    var size: UInt {
        UInt(count * MemoryLayout<Element>.stride)
    }
}
