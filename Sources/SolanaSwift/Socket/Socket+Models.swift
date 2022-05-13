import Foundation

public typealias SocketAccountResponse = BufferInfo<EmptyInfo>
public struct SocketSignatureResponse: Decodable {
    
}

public struct SocketObservableAccount: Equatable {
    public let pubkey: String
    public let isNative: Bool
    
    public init(pubkey: String, isNative: Bool) {
        self.pubkey = pubkey
        self.isNative = isNative
    }
}

public struct SocketSubscription: Equatable {
    let entity: Entity
    let id: UInt64
    var account: String?
}
