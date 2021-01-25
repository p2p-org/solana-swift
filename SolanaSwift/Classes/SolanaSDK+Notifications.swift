//
//  SolanaSDK+Notifications.swift
//  SolanaSwift
//
//  Created by Chung Tran on 03/12/2020.
//

import Foundation

public extension SolanaSDK {
    struct Notification {
        public typealias Account = Rpc<SolanaSDK.BufferInfo<AccountInfo>>
        public struct Signature: Decodable {
            let err: ResponseError?
        }
    }
}
