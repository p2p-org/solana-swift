//
//  APIClientTests.swift
//  
//
//  Created by Alexey Sidorov on 25.04.2022.
//

import XCTest
import SolanaSwift

class APIClientTests: XCTestCase {
    
    let endpoint = SolanaSDK.APIEndPoint(
        address: "https://api.mainnet-beta.solana.com",
        network: .mainnetBeta
    )
    var solanaSDK: SolanaSDK!

    override func setUpWithError() throws {
        let accountStorage = InMemoryAccountStorage()
        solanaSDK = SolanaSDK(endpoint: endpoint, accountStorage: accountStorage)
        let account = try SolanaSDK.Account(phrase: endpoint.network.testAccount.components(separatedBy: " "), network: endpoint.network)
        try accountStorage.save(account)
    }

    override func tearDownWithError() throws {
        
    }

    func testGetAccount() async throws {
        let mock = JSONRPCAPIClient(endpoint: endpoint)
        let requestConfig = RequestConfiguration(encoding: "base64")
//        let request = RequestAPI(method: "getAccountInfo", params: ["HWbsF542VSCxdGKcHrXuvJJnpwCEewmzdsG6KTxXMRRk", requestConfig])
//        let request2 = RequestAPI(method: "getAccountInfo", params: ["HWbsF542VSCxdGKcHrXuvJJnpwCEewmzdsG6KTxXMRRk", requestConfig])
//        let request3 = RequestAPI(method: "getBlockHeight", params: [])
        
//        let req1 = JSONRPCAPIClient.RequestEncoder.RequestType(method: "getAccountInfo", params: ["HWbsF542VSCxdGKcHrXuvJJnpwCEewmzdsG6KTxXMRRk", requestConfig])
//        let res: AnyResponse<Rpc<BufferInfo<AccountInfo>>> = try await mock.perform(request: req1)
//        let res1: AnyResponse<Int> = try await mock.perform(request: req1)
//        print("**** \(res)")
        
        
        let result1: BufferInfo<AccountInfo> = try! await mock.getAccountInfo(account: "HWbsF542VSCxdGKcHrXuvJJnpwCEewmzdsG6KTxXMRRk")
        print(result1)
        
        
//        let result: AnyResponse<[Rpc<BufferInfo<EmptyInfo>?>]> = try await mock.perform(requests: [request, request3])
//        XCTAssert(result.result != nil)
//        print(result.result)
//        print(result.error)
//        print(result.result?.value?.data.owner)
        
//        let data: BufferInfo<AccountInfo> = try await mock.getAccountInfo(account: "HWbsF542VSCxdGKcHrXuvJJnpwCEewmzdsG6KTxXMRRk")
//        XCTAssert(result.result?.value?.data.owner == data.data.owner)
    }
    
//    func testWithMock() async throws {
//        let mock = MockAPIClient()
////        let requestConfig = RequestConfiguration(encoding: "base64")
////        let request = RequestAPI(method: "getAccountInfo", params: ["HWbsF542VSCxdGKcHrXuvJJnpwCEewmzdsG6KTxXMRRk", requestConfig])
////        let result: AnyResponse<Rpc<BufferInfo<AccountInfo>?>> = try await mock.perform(request: request)
////        XCTAssert(result.result != nil)
////        print(result.result?.value?.data.owner)
//
////        let data: BufferInfo<AccountInfo> = try await mock.getAccountInfo(account: "HWbsF542VSCxdGKcHrXuvJJnpwCEewmzdsG6KTxXMRRk")
////        XCTAssert(result.result?.value?.data.owner == data.data.owner)
//        let data: BufferInfo<AccountInfo> = try await mock.getAccountInfo(account: "HWbsF542VSCxdGKcHrXuvJJnpwCEewmzdsG6KTxXMRRk")
//        XCTAssert(data.data.owner == "")
//
//    }
//
//    class MockAPIClient: SolanaAPIClient {
//
//        func getAccountInfo<T>(account: String) async throws -> BufferInfo<T> where T : DecodableBufferLayout {
//            ...
//        }
//
//        func perform<Entity>(request: RequestAPI) async throws -> AnyResponse<Entity> where Entity : Decodable {
//            let str = "{\"jsonrpc\":\"2.0\",\"result\":{\"context\":{\"slot\":131421172},\"value\":{\"data\":[\"xvp6877brTo9ZfNqq8l0MbG75MLS9uDkfKYCA0UvXWF9P8kKbTPTsQZqMMzOan8jwyOl0jQaxrCPh8bU1ysTa96DDAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\",\"base64\"],\"executable\":false,\"lamports\":2039280,\"owner\":\"TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA\",\"rentEpoch\":304}},\"id\":\"6B1C0860-44BE-4FA9-9F57-CB14BC7636BB\"}\n".data(using: .utf8)!
//            let json = try! JSONSerialization.jsonObject(with: str, options: [])
//            let data = try! JSONEncoder().encode(json)
//            return try JSONRPCResponse<BufferInfo<T>>(data: data)!.result!
//        }
//
//        func perform<Entity>(requests: [RequestAPI]) async throws -> AnyResponse<Entity> where Entity : Decodable {
//            fatalError()
//        }
//
//        typealias RequestEncoder = JSONRPCRequestEncoder
//    }

}
