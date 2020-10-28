//
//  InMemoryAccountStorage.swift
//  p2p_walletTests
//
//  Created by Chung Tran on 10/28/20.
//

import Foundation
import SolanaSwift

class InMemoryAccountStorage: SolanaSDKAccountStorage {
    static let accountPhraseToTest = "bar message old wage miss habit side coral hour learn exhaust tool"
    private var _account: SolanaSDK.Account?
    func save(_ account: SolanaSDK.Account) throws {
        _account = account
    }
    var account: SolanaSDK.Account? {
        _account
    }
}
