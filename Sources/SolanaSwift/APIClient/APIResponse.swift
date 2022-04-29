import Foundation

public protocol APIClientResponse: Decodable {
    associatedtype Entity: Decodable
    var result: Entity? {get}
    var error: ResponseError? {get}
}

/// Class is used to wrap Entity to not be responsible from a concrete type
public struct AnyResponse<Entity: Decodable>: APIClientResponse {
    public var result: Entity?
    public var error: ResponseError?
    
    init<T: APIClientResponse>(_ response: T) where T.Entity == Entity {
        self.result = response.result
        self.error = response.error
    }
}

public struct JSONRPCResponse<Entity: Decodable>: APIClientResponse {
    public let jsonrpc: String
    public let id: String?
    public let result: Entity?
    public let error: ResponseError?
    public let method: String?
}

public class JSONRPCResponseDecoder<Entity: Decodable> {
    public func decode(with data: Data) throws -> Entity {
        return try JSONDecoder().decode(Entity.self, from: data)
    }
}
