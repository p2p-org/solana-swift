//
//  RenVM+RPCClient.swift
//  Alamofire
//
//  Created by Chung Tran on 15/09/2021.
//

import Foundation
import RxAlamofire
import RxSwift

public protocol RenVMRpcClientType {
    var network: RenVM.Network {get}
    func call<T: Decodable>(endpoint: String, method: String, params: Encodable, log: Bool) -> Single<T>
    func selectPublicKey(mintTokenSymbol: String) -> Single<Data?>
}

public extension RenVMRpcClientType {
    private var emptyParams: [String: String] {[:]}
    func queryMint(txHash: String) -> Single<RenVM.ResponseQueryTxMint> {
        call(endpoint: network.lightNode, method: "ren_queryTx", params: ["txHash": txHash], log: true)
    }
    
    func queryBlockState(log: Bool = false) -> Single<RenVM.ResponseQueryBlockState> {
        call(endpoint: network.lightNode, method: "ren_queryBlockState", params: emptyParams, log: log)
    }

    func queryConfig() -> Single<RenVM.ResponseQueryConfig> {
        call(endpoint: network.lightNode, method: "ren_queryConfig", params: emptyParams, log: true)
    }

    internal func submitTx(
        hash: String,
        selector: RenVM.Selector,
        version: String,
        input: RenVM.MintTransactionInput
    ) -> Single<RenVM.ResponseSubmitTxMint> {
        call(
            endpoint: network.lightNode,
            method: "ren_submitTx",
            params: ["tx": RenVM.ParamsSubmitMint(
                hash: hash,
                selector: selector.toString(),
                version: version,
                in: .init(
                    t: .init(),
                    v: input
                )
            )],
            log: true
        )
    }
    
    func selectPublicKey(mintTokenSymbol: String) -> Single<Data?> {
        queryBlockState()
            .map {
                Data(base64urlEncoded: $0.publicKey(mintTokenSymbol: mintTokenSymbol) ?? "")
            }
    }
    
    func getTransactionFee(mintTokenSymbol: String) -> Single<UInt64> {
        // TODO: - Remove later: Support other tokens
        if mintTokenSymbol != "BTC" {
            return .error(RenVM.Error("Unsupported token"))
        }
        
        return queryBlockState(log: true)
            .map {blockState in
                guard let gasLimit = UInt64(blockState.state.v.btc.gasLimit),
                      let gasCap = UInt64(blockState.state.v.btc.gasCap)
                else {throw RenVM.Error("Could not calculate transaction fee")}
                return gasLimit * gasCap
            }
    }
}

extension RenVM {
    public struct RpcClient: RenVMRpcClientType {
        public init(network: RenVM.Network) {
            self.network = network
        }
        
        public let network: RenVM.Network
        
        public func call<T>(endpoint: String, method: String, params: Encodable, log: Bool) -> Single<T> where T : Decodable {
            do {
                // prepare params
                let params = EncodableWrapper.init(wrapped:params)
                
                // Log
                if log {
                    Logger.log(message: "renBTC event \(method) \(params.jsonString ?? "")", event: .request, apiMethod: method)
                }
                
                // prepare urlRequest
                let body = Body(method: method, params: params)
                
                var urlRequest = try URLRequest(
                    url: endpoint,
                    method: .post,
                    headers: [.contentType("application/json")]
                )
                urlRequest.httpBody = try JSONEncoder().encode(body)
                
                // request
                return request(urlRequest)
                    .responseData()
                    .map {(response, data) -> T in
                        // Print
                        if log {
//                            Logger.log(message: "renBTC event  " + method + " " + (String(data: data, encoding: .utf8) ?? ""), event: .response, apiMethod: method)
                        }
                        
                        let statusCode = response.statusCode
                        let isValidStatusCode = (200..<300).contains(statusCode)
                        
                        let res = try JSONDecoder().decode(Response<T>.self, from: data)
                        
                        if isValidStatusCode, let result = res.result {
                            return result
                        }
                        
                        throw res.error ?? .unknown
                    }
                    .take(1)
                    .asSingle()
            } catch {
                return .error(error)
            }
        }
        
        struct Body: Encodable {
            let id = 1
            let jsonrpc = "2.0"
            let method: String
            let params: EncodableWrapper
        }
        
        struct EncodableWrapper: Encodable {
            let wrapped: Encodable
            
            public func encode(to encoder: Encoder) throws {
                try self.wrapped.encode(to: encoder)
            }
        }
        
        struct Response<T: Decodable>: Decodable {
            public let jsonrpc: String
            public let id: Int?
            public let result: T?
            public let error: RenVM.Error?
            public let method: String?
        }
    }
}
