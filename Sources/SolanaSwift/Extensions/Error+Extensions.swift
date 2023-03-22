//
//  Error+Extensions.swift
//  p2p_wallet
//
//  Created by Chung Tran on 10/03/2021.
//

import Foundation
import Task_retrying

public extension Error {
    var readableDescription: String {
        (self as? LocalizedError)?.errorDescription ?? "\(self)"
    }

    func isEqualTo(_ error: SolanaError) -> Bool {
        (self as? SolanaError) == error
    }

    var isAlreadyInUseSolanaError: Bool {
        if let error = self as? SolanaError {
            switch error {
            case let .invalidResponse(response):
                return response.data?.logs?.contains(where: \.isAlreadyInUseLog) == true
            default:
                break
            }
        }
        return false
    }
    
    var isSolanaBlockchainRelatedError: Bool {
        guard let error = ((self as? APIClientError) ?? // APIClientError
            ((self as? TaskRetryingError)?.lastError as? APIClientError)) // Retrying with last error
        else {
            return false
        }
        switch error {
        case .responseError:
            return true
        default:
            return false
        }
    }
}

private extension String {
    var isAlreadyInUseLog: Bool {
        starts(with: "Allocate: account Address { address: ") &&
            hasSuffix("} already in use")
    }
}
