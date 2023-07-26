import Foundation

public protocol APIClientResponse: Decodable {
    associatedtype Entity: Decodable
    var result: Entity? { get }
    var error: ResponseError? { get }
}

/// Class is used to wrap Entity to not be responsible from a concrete type
public struct AnyResponse<Entity: Decodable>: APIClientResponse {
    public var result: Entity?
    public var error: ResponseError?

    public init<T: APIClientResponse>(_ response: T) where T.Entity == Entity {
        result = response.result
        error = response.error
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            result = try container.decodeIfPresent(Entity.self, forKey: .result) ?? nil
        } catch let error as APIClientError {
            throw error
        } catch {
            result = nil
        }
        error = try container.decodeIfPresent(ResponseError.self, forKey: .error)
    }

    enum CodingKeys: String, CodingKey {
        case result
        case error
    }
}

public struct JSONRPCResponse<Entity: Decodable>: APIClientResponse {
    public let jsonrpc: String
    public let id: String?
    public let result: Entity?
    public let error: ResponseError?
    public let method: String?

    public init(id: String? = nil, result: Entity? = nil, error: ResponseError? = nil, method: String? = nil) {
        jsonrpc = "2.0"
        self.id = id ?? ""
        self.result = result
        self.error = error
        self.method = method
    }
}

public class JSONRPCResponseDecoder<Entity: Decodable> {
    public func decode(with data: Data) throws -> Entity {
        try JSONDecoder().decode(Entity.self, from: data)
    }
}
