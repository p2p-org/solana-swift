//
//  InMemoryAccountStorage.swift
//  p2p_walletTests
//
//  Created by Chung Tran on 10/28/20.
//

import Foundation
import SolanaSwift

extension SolanaSDK.Network {
    var testAccount: String {
        switch self {
        case .mainnetBeta:
            return "miracle pizza supply useful steak border same again youth silver access hundred"
        case .devnet:
            return "galaxy lend nose glow equip student way hockey step dismiss expect silent"
        default:
            fatalError("unsupported")
        }
    }
}

class InMemoryAccountStorage: SolanaSDKAccountStorage {
    private var _account: SolanaSDK.Account?
    func save(_ account: SolanaSDK.Account) throws {
        _account = account
    }
    var account: SolanaSDK.Account? {
        _account
    }
}
