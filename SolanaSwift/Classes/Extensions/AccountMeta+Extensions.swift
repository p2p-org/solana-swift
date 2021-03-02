//
//  AccountMeta+Extensions.swift
//  SolanaSwift
//
//  Created by Chung Tran on 02/03/2021.
//

import Foundation

extension Array where Element == SolanaSDK.Account.Meta {
    public mutating func sort() {
        let defaultSorter: ((Element, Element) -> Bool) = { lhs, rhs in
            if lhs.isSigner != rhs.isSigner {return lhs.isSigner}
            if lhs.isWritable != rhs.isWritable {return lhs.isWritable}
            return false
        }
        
        sort(by: defaultSorter)
    }
}
