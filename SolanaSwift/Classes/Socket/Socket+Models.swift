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
    
    struct Subscription: Equatable {
        let entity: Entity
        let id: UInt64
        var account: String?
    }
}


private extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
}
