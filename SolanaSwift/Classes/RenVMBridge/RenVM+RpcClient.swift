//
//  RenVM+RpcClient.swift
//  SolanaSwift
//
//  Created by Chung Tran on 09/09/2021.
//

import Foundation
import RxSwift

public protocol RenVMRpcClientType {
    var network: RenVM.Network {get}
    func call<T: Decodable>(endpoint: String, params: Encodable) -> Single<T>
    func selectPublicKey() -> Single<Data?>
}

public extension RenVMRpcClientType {
    private var emptyParams: [String: String] {[:]}
    func queryMint(txHash: String) -> Single<RenVM.ResponseQueryTxMint> {
        call(endpoint: "ren_queryTx", params: ["txHash": txHash])
    }
    
    func queryBlockState() -> Single<RenVM.ResponseQueryBlockState> {
        call(endpoint: "ren_queryBlockState", params: emptyParams)
    }

    func queryConfig() -> Single<RenVM.ResponseQueryConfig> {
        call(endpoint: "ren_queryConfig", params: emptyParams)
    }

    internal func submitTxMint(
        hash: String,
        input: RenVM.MintTransactionInput
    ) -> Single<RenVM.ResponseSubmitTxMint> {
        call(endpoint: "ren_submitTx", params: RenVM.ParamsSubmitMint(hash: hash, input: input))
    }
    
    func selectPublicKey() -> Single<Data?> {
        queryBlockState()
            .map {Data(base64Encoded: $0.publicKey ?? "")}
    }
}

public protocol RenVMSolanaAPIClientType {
    func getAccountInfo<T: DecodableBufferLayout>(account: String, decodedTo: T.Type) -> Single<SolanaSDK.BufferInfo<T>>
    func getMintData(
        mintAddress: String,
        programId: String
    ) -> Single<SolanaSDK.Mint>
    func getConfirmedSignaturesForAddress2(account: String, configs: SolanaSDK.RequestConfiguration?) -> Single<[SolanaSDK.SignatureInfo]>
}
