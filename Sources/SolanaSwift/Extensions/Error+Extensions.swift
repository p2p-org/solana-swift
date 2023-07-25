//
//  Error+Extensions.swift
//  p2p_wallet
//
//  Created by Chung Tran on 10/03/2021.
//

import Foundation
import Task_retrying

extension Error {
    func isEqualTo(_ error: SolanaError) -> Bool {
        (self as? SolanaError) == error
    }

    func isEqualTo(_ error: TransactionConfirmationError) -> Bool {
        (self as? TransactionConfirmationError) == error
    }
}
