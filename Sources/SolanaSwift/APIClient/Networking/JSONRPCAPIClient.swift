import Foundation

/// JSON RPC
public class JSONRPCAPIClient: SolanaAPIClient {
    public typealias ResponseDecoder = JSONRPCResponseDecoder
    public typealias RequestEncoder = JSONRPCRequestEncoder
    
    // MARK: -
    
    private let endpoint: APIEndPoint
    private let networkManager: NetworkManager
    
    public init(endpoint: APIEndPoint, networkManager: NetworkManager = URLSession(configuration: .default)) {
        self.endpoint = endpoint
        self.networkManager = networkManager
    }
    
    public func request(with requests: [RequestEncoder.RequestType]) async throws -> [AnyResponse<RequestEncoder.RequestType.Entity>] {
        let data = try await self.makeRequest(requests: requests)
        let response = try ResponseDecoder<[AnyResponse<AnyDecodable>]>().decode(with: data)
        let ret = response.map({ resp in
            return AnyResponse<RequestEncoder.RequestType.Entity>(resp)
        })
        return ret
    }
    
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
