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

public protocol RenVMSolanaAPIClientType {
    func getAccountInfo<T: DecodableBufferLayout>(account: String, decodedTo: T.Type) -> Single<SolanaSDK.BufferInfo<T>>
    func getMintData(
        mintAddress: String,
        programId: String
    ) -> Single<SolanaSDK.Mint>
    func getConfirmedSignaturesForAddress2(account: String, configs: SolanaSDK.RequestConfiguration?) -> Single<[SolanaSDK.SignatureInfo]>
}
