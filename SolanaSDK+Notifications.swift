//
//  SolanaSDK+Notifications.swift
//  SolanaSwift
//
//  Created by Chung Tran on 03/12/2020.
//

import Foundation

public extension SolanaSDK {
    struct Notification {
        struct Account: Decodable {
            public let subscription: Int64
            public let result: Rpc<SolanaSDK.AccountInfo<AccountLayout>>
        }
    }
}
