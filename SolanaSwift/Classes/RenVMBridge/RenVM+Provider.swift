//
//  RenVM+Provider.swift
//  SolanaSwift
//
//  Created by Chung Tran on 09/09/2021.
//

import Foundation
import RxSwift

protocol RenVMProviderType {
    func selectPublicKey() -> Single<Data?>
    func submitMint(
        gHash: Data,
        gPubkey: Data,
        nHash: Data,
        nonce: Data,
        amount: String,
        pHash: Data,
        to: String,
        txIndex: String,
        txid: Data
    ) -> Single<String>
    func queryMint(txHash: String) -> Single<RenVM.ResponseQueryTxMint>
}

extension RenVM {
    public class Provider: RenVMProviderType {
        private let client: RenVMRpcClientType
        private var emptyParams = [String: String]()
        
        public init(client: RenVMRpcClientType) {
            self.client = client
        }
        
        public func queryMint(txHash: String) -> Single<ResponseQueryTxMint> {
            client.call(endpoint: "ren_queryTx", params: ["txHash": txHash])
        }
        
        public func queryBlockState() -> Single<ResponseQueryBlockState> {
            client.call(endpoint: "ren_queryBlockState", params: emptyParams)
        }

        public func queryConfig() -> Single<ResponseQueryConfig> {
            client.call(endpoint: "ren_queryConfig", params: emptyParams)
        }

        func submitTxMint(
            hash: String,
            input: MintTransactionInput
        ) -> Single<ResponseSubmitTxMint> {
            client.call(endpoint: "ren_submitTx", params: ParamsSubmitMint(hash: hash, input: input))
        }
        
        func selectPublicKey() -> Single<Data?> {
            queryBlockState()
                .map {Data(base64Encoded: $0.publicKey ?? "")}
        }
        
        func submitMint(
            gHash: Data,
            gPubkey: Data,
            nHash: Data,
            nonce: Data,
            amount: String,
            pHash: Data,
            to: String,
            txIndex: String,
            txid: Data
        ) -> Single<String> {
            let mintTx = MintTransactionInput(gHash: gHash, gPubkey: gPubkey, nHash: nHash, nonce: nonce, amount: amount, pHash: pHash, to: to, txIndex: txIndex, txid: txid)
            let hash: String
            do {
                hash = try mintTx.hash().base64urlEncodedString()
            } catch {
                return .error(error)
            }
            
            return submitTxMint(hash: hash, input: mintTx)
                .map {_ in hash}
        }
        
        func mintTxHash(
            gHash: Data,
            gPubkey: Data,
            nHash: Data,
            nonce: Data,
            amount: String,
            pHash: Data,
            to: String,
            txIndex: String,
            txid: Data
        ) throws -> String {
            let mintTx = MintTransactionInput(gHash: gHash, gPubkey: gPubkey, nHash: nHash, nonce: nonce, amount: amount, pHash: pHash, to: to, txIndex: txIndex, txid: txid)
            let hash = try mintTx.hash().base64urlEncodedString()
            return hash
        }
    }
}
