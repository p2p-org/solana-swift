//
//  Error+Extensions.swift
//  p2p_wallet
//
//  Created by Chung Tran on 10/03/2021.
//

import Foundation

extension Error {
    public var readableDescription: String {
        (self as? LocalizedError)?.errorDescription ?? localizedDescription
    }
    
    public func isEqualTo(_ error: SolanaSDK.Error) -> Bool {
        (self as? SolanaSDK.Error) == error
    }
}
