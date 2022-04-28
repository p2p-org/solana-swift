import Foundation
import RxSwift

public protocol SolanaAPIClient {
    associatedtype RequestEncoder: APIClientRequestEncoder

    // API Methods
    func getAccountInfo<T: DecodableBufferLayout>(account: String) async throws -> BufferInfo<T>
    func getBalance(account: String, commitment: Commitment?) async throws -> UInt64
    func getBlockCommitment(block: UInt64) async throws -> BlockCommitment
    func getBlockTime(block: UInt64) async throws -> Date
    func getBlockHeight() async throws -> UInt64
    func getConfirmedBlocksWithLimit(startSlot: UInt64, limit: UInt64) async throws -> [UInt64]
    

    // Requests
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
    
    public func getBalance(account: String, commitment: Commitment? = nil) async throws -> UInt64 {
        let req = RequestEncoder.RequestType(method: "getBalance", params: [account, RequestConfiguration(commitment: commitment)])
        let response: AnyResponse<Rpc<UInt64>> = try await request(with: req)
        guard let result = response.result else {
            throw APIClientError.cantDecodeResponse
        }
        return result.value
    }
    
    public func getBlockCommitment(block: UInt64) async throws -> BlockCommitment {
        let req = RequestEncoder.RequestType(method: "getBlockCommitment", params: [block])
        let response: AnyResponse<BlockCommitment> = try await request(with: req)
        guard let result = response.result else {
            throw APIClientError.cantDecodeResponse
        }
        return result
    }
    
    public func getBlockTime(block: UInt64) async throws -> Date {
        let req = RequestEncoder.RequestType(method: "getBlockTime", params: [block])
        let response: AnyResponse<Double> = try await request(with: req)
        guard let resp = response.result else { throw APIClientError.cantDecodeResponse }
        return Date(timeIntervalSince1970: TimeInterval(resp))
    }

}
