//
//  RenVM.swift
//  Alamofire
//
//  Created by Chung Tran on 09/09/2021.
//

import Foundation
import RxSwift

public struct RenVM {
    
}

public protocol RenVMChainType {
    var chainName: String {get}
    func getAssociatedTokenAddress(
        address: Data,
        mintTokenSymbol: String
    ) throws -> Data // represent as data, because there might be different encoding methods for various of chains
    func dataToAddress(
        data: Data
    ) throws -> String
    
    func signatureToData(
        signature: String
    ) throws -> Data
    
    func submitMint(
        address: Data,
        mintTokenSymbol: String,
        signer: Data,
        responceQueryMint: RenVM.ResponseQueryTxMint
    ) -> Single<String>
    
    func submitBurn(
        mintTokenSymbol: String,
        account: Data,
        amount: String,
        recipient: String,
        signer: Data
    ) -> Single<RenVM.BurnDetails>
}

extension RenVMChainType {
    func selector(mintTokenSymbol: String, direction: RenVM.Selector.Direction) -> RenVM.Selector {
        .init(mintTokenSymbol: mintTokenSymbol, chainName: chainName, direction: direction)
    }
}

public protocol RenVMRpcClientType {
    var network: RenVM.Network {get}
    func call<T: Decodable>(endpoint: String, method: String, params: Encodable) -> Single<T>
    func selectPublicKey(mintTokenSymbol: String) -> Single<Data?>
}

public extension RenVMRpcClientType {
    private var emptyParams: [String: String] {[:]}
    func queryMint(txHash: String) -> Single<RenVM.ResponseQueryTxMint> {
        call(endpoint: network.lightNode, method: "ren_queryTx", params: ["txHash": txHash])
    }
    
    func queryBlockState() -> Single<RenVM.ResponseQueryBlockState> {
        call(endpoint: network.lightNode, method: "ren_queryBlockState", params: emptyParams)
    }

    func queryConfig() -> Single<RenVM.ResponseQueryConfig> {
        call(endpoint: network.lightNode, method: "ren_queryConfig", params: emptyParams)
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
            )]
        )
    }
    
    func selectPublicKey(mintTokenSymbol: String) -> Single<Data?> {
        queryBlockState()
            .map {
                Data(base64urlEncoded: $0.publicKey(mintTokenSymbol: mintTokenSymbol) ?? "")
            }
    }
}
