//
//  AccountMeta+Extensions.swift
//  SolanaSwift
//
//  Created by Chung Tran on 02/04/2021.
//

import Foundation

extension Array where Element == AccountMeta {
    func index(ofElementWithPublicKey publicKey: PublicKey) throws -> Int {
        guard let index = firstIndex(where: { $0.publicKey == publicKey })
        else { throw SolanaError.other("Could not found accountIndex") }
        return index
    }
}
