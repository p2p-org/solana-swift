//
//  Socket+Status.swift
//  SolanaSwift
//
//  Created by Chung Tran on 31/05/2021.
//

import Foundation

extension SolanaSDK.Socket {
    enum Status: Equatable {
        case initializing
        case connecting
        case connected
        case disconnected
        case error(Error)
        
        static func == (rhs: Self, lhs: Self) -> Bool {
            switch (lhs, rhs) {
            case (.initializing, .initializing), (.connected, .connected), (.disconnected, .disconnected):
                return true
            case (.error(let err1), .error(let err2)):
                return err1.readableDescription == err2.readableDescription
            default:
                return false
            }
        }
        
        var isError: Bool {
            switch self {
            case .error:
                return true
            default:
                return false
            }
        }
    }
}
