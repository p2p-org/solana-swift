import Foundation
import RxSwift

public protocol SolanaAPIClient {
    associatedtype RequestEncoder: APIClientRequestEncoder

    func getAccountInfo<T: DecodableBufferLayout>(account: String) async throws -> BufferInfo<T>

    // TODO: rename to request
    func perform<Entity: Decodable>(request: RequestEncoder.RequestType) async throws -> AnyResponse<Entity>
    func perform(requests: [RequestEncoder.RequestType]) async throws -> [AnyResponse<RequestEncoder.RequestType.Entity>]
}

public enum APIClientError: Error {
    case cantEncodeParams
    case invalidAPIURL
    case cantDecodeResponse
}

/// Solana API Methods
extension SolanaAPIClient {
    
    public func getAccountInfo<T: DecodableBufferLayout>(account: String) async throws -> BufferInfo<T> {
        let requestConfig = RequestConfiguration(encoding: "base64")
        let request = RequestEncoder.RequestType(method: "getAccountInfo", params: [account, requestConfig])
        
        let response: AnyResponse<Rpc<T>> = try await perform(request: request)
        
        fatalError()
//        guard let ret = response.result else {
//            throw APIClientError.cantDecodeResponse
//        }
//        return ret
    }
    
//    public func getBlockHeight() async throws -> [UInt64] {
//        let request = RequestEncoder.RequestType(method: "getBlockHeight", params: [])
//        let response: AnyRespons<UInt64> = try await perform(request: request)
//        guard let result = response.result else {
//            throw APIClientError.cantDecodeResponse
//        }
//        return [result]
//    }
    
//    func getConfirmedBlocksWithLimit(startSlot: UInt64, limit: UInt64) -> [UInt64] {
//        let request = RequestEncoder.RequestType(method: "getConfirmedBlocksWithLimit", params: [startSlot, limit])
//        return try await perform(request: request)
//    }
}

/// JSON RPC
public class JSONRPCAPIClient: SolanaAPIClient {
    public typealias ResponseDecoder = JSONRPCResponseDecoder
    public typealias RequestEncoder = JSONRPCRequestEncoder
    
    // MARK: -
    
    private let endpoint: APIEndPoint
    
    public init(endpoint: APIEndPoint) {
        self.endpoint = endpoint
    }
    
    @available(iOS 13.0.0, *)
    @available(macOS 10.15.0, *)
    public func perform(requests: [RequestEncoder.RequestType]) async throws -> [AnyResponse<RequestEncoder.RequestType.Entity>] {
        var encodedParams: Data = Data()
        do {
            encodedParams += try RequestEncoder(requests: requests).encoded()
        } catch {
            throw APIClientError.cantEncodeParams
        }
        let urlRequest = try self.urlRequest(data: encodedParams)
        
        let urlSessionConfiguration = URLSessionConfiguration.default
        
        let urlSession = URLSession(configuration: urlSessionConfiguration)
        let (data, _): (Data, URLResponse)
        if #available(iOS 15.0, *) {
            (data, _) = try await urlSession.data(for: urlRequest)
        } else {
            (data, _) = try await urlSession.data(from: urlRequest)
        }
        let response = try ResponseDecoder<[AnyResponse<AnyDecodable>]>().decode(with: data)
        let ret = response.map({ resp in
            return AnyResponse<RequestEncoder.RequestType.Entity>(resp)
        })
        return ret
    }
    
    @available(iOS 13.0.0, *)
    @available(macOS 10.15.0, *)
    public func perform<Entity: Decodable>(request: RequestEncoder.RequestType) async throws -> AnyResponse<Entity> {
        let response = try await perform(requests: [request])
        // Need to cast AnyCodable to Entity
        guard let first = response.first, var newResponse = AnyResponse<Entity>(with: first) else {
            throw APIClientError.cantDecodeResponse
        }
        newResponse.error = first.error
        return newResponse
    }
    
    // MARK: - Private
    
    private func urlRequest(data: Data) throws -> URLRequest {
        guard let url = URL(string: self.endpoint.getURL()) else { throw APIClientError.invalidAPIURL }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpBody = data
        urlRequest.httpMethod = "POST"
        urlRequest.headers = ["Content-Type": "application/json; charset=utf-8"]
        return urlRequest
    }
}
