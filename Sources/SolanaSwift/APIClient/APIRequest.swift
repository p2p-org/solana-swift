import Foundation

public protocol APIClientRequest: Encodable {
    /// Expected entity with this request. Used to decode response to
    /// Can use AnyDecodable
    associatedtype Entity: Decodable
    init(method: String, params: [Encodable])
}

public struct JSONRPCAPIClientRequest<Entity: Decodable>: APIClientRequest {
    public init(method: String, params: [Encodable]) {
        self.method = method
        self.params = params
    }
    
    public let id = UUID().uuidString
    public let method: String
    public let jsonrpc = "2.0"
    public let params: [Encodable]
    
    enum CodingKeys: String, CodingKey {
        case id
        case method
        case jsonrpc
        case params
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(method, forKey: .method)
        try container.encode(jsonrpc, forKey: .jsonrpc)
        let wrappedDict = params.map(EncodableWrapper.init(wrapped:))
        try container.encode(wrappedDict, forKey: .params)
    }
}

/// Encoder used to encode request in able to use with the transport
public protocol APIClientRequestEncoder {
    associatedtype RequestType: APIClientRequest
    
    init(request: RequestType)
    init(requests: [RequestType])
    
    func encoded() throws -> Data
}

/// JSONRPCRequestEncoder encodes requests of type RequestAPI according to JSONRPC rules
public class JSONRPCRequestEncoder: APIClientRequestEncoder {
    public typealias RequestType = JSONRPCAPIClientRequest<AnyDecodable>
    
    private var requests = [RequestType]()
    
    required public init(request: RequestType) {
        requests = [request]
    }
    
    required public init(requests: [RequestType]) {
        self.requests = requests
    }
    
    public func encoded() throws -> Data {
        try JSONEncoder().encode(requests)
    }
}
