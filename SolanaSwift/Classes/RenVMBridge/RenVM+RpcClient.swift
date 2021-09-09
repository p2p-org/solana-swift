//
//  RenVM+RpcClient.swift
//  SolanaSwift
//
//  Created by Chung Tran on 09/09/2021.
//

import Foundation
import RxSwift

public protocol RenVMRpcClientType {
    init(_ network: RenVM.Network)
    func call<T: Decodable>(endpoint: String, params: Encodable) -> Single<T>
}
