//
//  RenVM+BurnDetails.swift
//  SolanaSwift
//
//  Created by Chung Tran on 14/09/2021.
//

import Foundation

extension RenVM {
    public struct BurnDetails {
        let confirmedSignature: String
        let nonce: BInt
        let recipient: String
    }
}
