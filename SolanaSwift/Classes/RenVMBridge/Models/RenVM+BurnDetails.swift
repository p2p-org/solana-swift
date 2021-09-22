//
//  RenVM+BurnDetails.swift
//  SolanaSwift
//
//  Created by Chung Tran on 14/09/2021.
//

import Foundation

extension RenVM {
    public struct BurnDetails: Codable {
        let confirmedSignature: String
        let nonce: UInt64
        let recipient: String
        let amount: String
    }
}
