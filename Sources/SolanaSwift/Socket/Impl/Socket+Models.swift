import Foundation

public typealias SocketAccountResponse = BufferInfo<EmptyInfo>
public struct SocketSignatureResponse: Decodable {
    
}

public struct SubscribingResultResponse: Decodable {
    let requestId: String
    let subscriptionId: UInt64
}

public enum SocketEntity: String {
    case account
    case signature
    
    var notificationMethodName: String {
        self.rawValue + "Notification"
    }
}

public struct SocketObservableAccount: Equatable, Hashable {
    public let pubkey: String
    public let isNative: Bool
    
    public init(pubkey: String, isNative: Bool) {
        self.pubkey = pubkey
        self.isNative = isNative
    }
}

public struct SocketSubscription: Equatable, Hashable {
    let entity: SocketEntity
    let id: UInt64
    var account: String?
}

public struct SocketMethod: Equatable {
    public enum Action: String {
        case subscribe
        case unsubscribe
    }
    
    public let entity: SocketEntity
    public let action: Action
    
    public init(_ entity: SocketEntity, _ action: Action) {
        self.entity = entity
        self.action = action
    }
    
    public var rawValue: String {
        entity.rawValue + action.rawValue.capitalizingFirstLetter()
    }
}

private extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
}
