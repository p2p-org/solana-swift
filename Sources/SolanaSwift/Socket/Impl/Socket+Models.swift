import Foundation

// MARK: - Response

public typealias SocketAccountResponse = Rpc<BufferInfo<EmptyInfo>>
public typealias SocketSignatureResponse = SignatureStatus

// MARK: - Notifications
public struct SocketResponse<T: Decodable>: Decodable {
    public let jsonrpc: String
    public let method: String?
    public let params: T?
    public let result: T?
}

public struct SocketResponseParams<T: Decodable>: Decodable {
    public let result: T?
    public let subscription: UInt64?
}

// MARK: - Request

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

public typealias SocketObservableSignature = String

public struct SocketSubscription<T: Equatable & Hashable>: Equatable, Hashable {
    let id: UInt64
    let item: T
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
