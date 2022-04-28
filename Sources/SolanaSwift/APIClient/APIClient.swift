import Foundation
import RxSwift

public protocol SolanaAPIClient {
    associatedtype RequestEncoder: APIClientRequestEncoder

    func getAccountInfo<T: DecodableBufferLayout>(account: String) async throws -> BufferInfo<T>
    func getBlockHeight() async throws -> UInt64
    func getConfirmedBlocksWithLimit(startSlot: UInt64, limit: UInt64) async throws -> [UInt64]

    // TODO: rename to request
    func request<Entity: Decodable>(with request: RequestEncoder.RequestType) async throws -> AnyResponse<Entity>
    func request(with requests: [RequestEncoder.RequestType]) async throws -> [AnyResponse<RequestEncoder.RequestType.Entity>]
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
        let req = RequestEncoder.RequestType(method: "getAccountInfo", params: [account, requestConfig])
        let response: AnyResponse<Rpc<BufferInfo<T>>> = try await request(with: req)
        guard let ret = response.result?.value else {
            throw APIClientError.cantDecodeResponse
        }
        return ret
    }
    
    public func getBlockHeight() async throws -> UInt64 {
        let req = RequestEncoder.RequestType(method: "getBlockHeight", params: [])
        let response: AnyResponse<UInt64> = try await request(with: req)
        guard let result = response.result else {
            throw APIClientError.cantDecodeResponse
        }
        return result
    }
    
    public func getConfirmedBlocksWithLimit(startSlot: UInt64, limit: UInt64) async throws -> [UInt64] {
        let req = RequestEncoder.RequestType(method: "getConfirmedBlocksWithLimit", params: [startSlot, limit])
        let response: AnyResponse<[UInt64]> = try await request(with: req)
        guard let result = response.result else {
            throw APIClientError.cantDecodeResponse
        }
        return result
    }
}

/// JSON RPC
public class JSONRPCAPIClient: SolanaAPIClient {
    public typealias ResponseDecoder = JSONRPCResponseDecoder
    public typealias RequestEncoder = JSONRPCRequestEncoder
    
    // MARK: -
    
    private let endpoint: APIEndPoint
    private let networkManager: NetworkManager
    
    public init(endpoint: APIEndPoint, networkManager: NetworkManager = APIClientNetworkManager()) {
        self.endpoint = endpoint
        self.networkManager = networkManager
    }
    
    @available(iOS 13.0.0, *)
    @available(macOS 10.15.0, *)
    public func request(with requests: [RequestEncoder.RequestType]) async throws -> [AnyResponse<RequestEncoder.RequestType.Entity>] {
        let data = try await self.makeRequest(requests: requests)
        
        let response = try ResponseDecoder<[AnyResponse<AnyDecodable>]>().decode(with: data)
        let ret = response.map({ resp in
            return AnyResponse<RequestEncoder.RequestType.Entity>(resp)
        })
        return ret
    }
    
    @available(iOS 13.0.0, *)
    @available(macOS 10.15.0, *)
    public func request<Entity: Decodable>(with request: RequestEncoder.RequestType) async throws -> AnyResponse<Entity> {
        let data = try await self.makeRequest(requests: [request])
        let response = try ResponseDecoder<[AnyResponse<Entity>]>().decode(with: data)
        guard let ret = response.first else {
            throw APIClientError.cantDecodeResponse
        }
        return ret
    }
    
    // MARK: - Private
    
    
    private func makeRequest(requests: [RequestEncoder.RequestType]) async throws -> Data {
        var encodedParams: Data = Data()
        do {
            encodedParams += try RequestEncoder(requests: requests).encoded()
        } catch {
            throw APIClientError.cantEncodeParams
        }
        let urlRequest = try self.urlRequest(data: encodedParams)
        
        return try await networkManager.requestData(request: urlRequest)
    }
    
    private func urlRequest(data: Data) throws -> URLRequest {
        guard let url = URL(string: self.endpoint.getURL()) else { throw APIClientError.invalidAPIURL }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpBody = data
        urlRequest.httpMethod = "POST"
        urlRequest.headers = ["Content-Type": "application/json; charset=utf-8"]
        return urlRequest
    }
}
