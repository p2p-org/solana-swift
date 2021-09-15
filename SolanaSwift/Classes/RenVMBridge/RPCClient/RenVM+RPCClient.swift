//
//  RenVM+RPCClient.swift
//  Alamofire
//
//  Created by Chung Tran on 15/09/2021.
//

import Foundation
import RxAlamofire
import RxSwift

extension RenVM {
    struct RpcClient: RenVMRpcClientType {
        let network: RenVM.Network
        
        func call<T>(endpoint: String, params: Encodable) -> Single<T> where T : Decodable {
            let body = Body(method: endpoint, params: EncodableWrapper(wrapped: params))
            fatalError()
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
    }
}
