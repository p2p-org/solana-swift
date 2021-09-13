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

    //    public String submitMInt(byte[] gHash, byte[] gPubKey, byte[] nHash, byte[] nonce, String amount, byte[] pHash,
    //            String to, String txIndex, byte[] txid) throws RpcException {
    //        MIntTransactionInput mIntTx = buildTransaction(gHash, gPubKey, nHash, nonce, amount, pHash, to, txIndex, txid)
    //        String hash = Utils.toURLBase64(hashTransactionMInt(mIntTx))
    //
    //        submitTxMInt(hash, mIntTx)
    //
    //        return hash
    //    }
        
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
            let input = MintTransactionInput(gHash: gHash, gPubkey: gPubkey, nHash: nHash, nonce: nonce, amount: amount, pHash: pHash, to: to, txIndex: txIndex, txid: txid)
            let hash = try Self.hashTransactionMint(input)
            return hash.base64urlEncodedString()
        }

        // txHash
        static func hashTransactionMint(_ mintTx: RenVM.MintTransactionInput) throws -> Data {
            var data = Data()
            let version = "1"
            let selector = "BTC/toSolana"
            data += marshal(src: version)
            data += marshal(src: selector)
            // marshalledType MintTransactionInput
            data += Base58
                .decode("aHQBEVgedhqiYDUtzYKdu1Qg1fc781PEV4D1gLsuzfpHNwH8yK2A2BuZK4uZoMC6pp8o7GWQxmsp52gsDrfbipkyeQZnXigCmscJY4aJDxF9tT8DQP3XRa1cBzQL8S8PTzi9nPnBkAxBhtNv6q1")
            
            guard let txidData = Data(base64urlEncoded: mintTx.txid)
            else {
                throw Error("Transaction id is not valid")
            }
            data += marshal(src: txidData)
            
            guard let txindex = UInt32(mintTx.txindex)?.bytes
            else {
                throw Error("txindex is not valid")
            }
            data += txindex
            
            let amount = try UInt256(mintTx.amount).serialize()
            data += amount
            
            data += Array(repeating: 0, count: 4)
            
            guard let phash = Data(base64urlEncoded: mintTx.phash)
            else {
                throw Error("phash is not valid")
            }
            data += phash
            
            data += marshal(src: mintTx.to)
            
            guard let nonce = Data(base64urlEncoded: mintTx.nonce)
            else {
                throw Error("nonce is not valid")
            }
            data += nonce
            
            guard let nhash = Data(base64urlEncoded: mintTx.nhash)
            else {
                throw Error("nhash is not valid")
            }
            data += nhash
            
            guard let gpubkey = Data(base64urlEncoded: mintTx.gpubkey)
            else {
                throw Error("gpubkey is not valid")
            }
            data += marshal(src: gpubkey)
            
            guard let ghash = Data(base64urlEncoded: mintTx.ghash)
            else {
                throw Error("ghash is not valid")
            }
            data += marshal(src: ghash)
            
            return data.sha256()
        }
    }
}

private func marshal(src: String) -> Data {
    marshal(src: Data(src.bytes))
}

private func marshal(src: Data) -> Data {
    var data = Data()
    data += UInt32(src.count).bytes
    data += src
    return data
}
