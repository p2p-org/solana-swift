//
//  Error+Extensions.swift
//  p2p_wallet
//
//  Created by Chung Tran on 10/03/2021.
//

import Foundation

extension Error {
    public var readableDescription: String {
        (self as? LocalizedError)?.errorDescription ?? "\(self)"
    }
    
    public func isEqualTo(_ error: SolanaSDK.Error) -> Bool {
        (self as? SolanaSDK.Error) == error
    }
    
    public var isAlreadyInUseSolanaError: Bool {
        if let error = self as? SolanaSDK.Error {
            switch error {
            case .invalidResponse(let response):
                return response.data?.logs?.contains(where: {$0.isAlreadyInUseLog}) == true
            default:
                break
            }
        }
        return false
    }
}

private extension String {
    var isAlreadyInUseLog: Bool {
        starts(with: "Allocate: account Address { address: ") &&
            hasSuffix("} already in use")
    }
}
