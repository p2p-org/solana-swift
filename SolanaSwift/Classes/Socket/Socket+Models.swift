//
//  Socket+Models.swift
//  SolanaSwift
//
//  Created by Chung Tran on 31/05/2021.
//

import Foundation

extension SolanaSDK.Socket {
    public enum Entity: String {
        case account
        case signature
        
        var notificationMethodName: String {
            self.rawValue + "Notification"
        }
    }
    
    public struct Method: Equatable {
        public enum Action: String {
            case subscribe
            case unsubscribe
        }
        
        public let entity: Entity
        public let action: Action
        
        public init(_ entity: Entity, _ action: Action) {
            self.entity = entity
            self.action = action
        }
        
        public var rawValue: String {
            entity.rawValue + action.rawValue.capitalizingFirstLetter()
        }
    }
    
    public struct Subscriber: Equatable {
        init(pubkey: String, isNative: Bool) {
            self.pubkey = pubkey
            self.isNative = isNative
        }
        
        let pubkey: String
        let isNative: Bool
    }
    
    public struct Subscription: Equatable {
        let entity: Entity
        let id: UInt64
        var account: String?
    }
    
    // MARK: - Notifications
    struct Response<T: Decodable>: Decodable {
        public let jsonrpc: String
        public let method: String?
        public let params: Params<T>?
        public let result: T?
    }
    
    struct Params<T: Decodable>: Decodable {
        public let result: SolanaSDK.Rpc<T>?
        public let subscription: UInt64?
    }
    
    struct AccountNotification<T: Decodable>: Decodable {
        public let data: T
        public let lamports: SolanaSDK.Lamports
        public let owner: String
        public let executable: Bool
        public let rentEpoch: UInt64
    }
    
    struct TokenAccountNotificationData: Decodable {
        public let program: String
        public let parsed: TokenAccountNotificationDataParsed
    }
    
    struct TokenAccountNotificationDataParsed: Decodable {
        public let type: String
        public let info: TokenAccountNotificationDataInfo
    }
    
    struct TokenAccountNotificationDataInfo: Decodable {
        public let tokenAmount: SolanaSDK.TokenAmount
        // TODO: - Another properties
        /*"isNative": false,
         "mint": "kinXdEcpDQeHPEuQnqmUgtYykqKGVFq6CeVX5iAHJq6",
         "owner": "6QuXb6mB6WmRASP2y8AavXh6aabBXEH5ZzrSH5xRrgSm",
         "state": "initialized",*/
    }
    
    public struct SignatureNotification: Decodable {
        let err: SolanaSDK.ResponseError?
    }
    
    typealias NativeAccountNotification = Response<AccountNotification<[String]>>
    typealias TokenAccountNotification = Response<AccountNotification<TokenAccountNotificationData>>
}


private extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
}
