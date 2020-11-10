//
//  Dictionary+Extension.swift
//  SolanaSwift
//
//  Created by Chung Tran on 11/10/20.
//

import Foundation

extension Array where Element == SolanaSDK.Account.Meta {
    mutating func append(contentsOf array: [Element]) {
        array.forEach {append($0)}
    }
    
    mutating func append(_ meta: Element) {
        let key = meta.publicKey.string
        if let index = firstIndex(where: {$0.publicKey.string == key}) {
            if !self[index].isWritable && meta.isWritable {
                self[index] = meta
            }
        } else {
            append(meta)
        }
    }
    
    mutating func sort() {
        sort(by: <)
    }
}
