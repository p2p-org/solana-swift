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

        public func submitTxMint(
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
            let hash = try hashTransactionMint(input)
            return hash.base64urlEncodedString()
        }

    //    public String mIntTxHash(byte[] gHash, byte[] gPubKey, byte[] nHash, byte[] nonce, String amount, byte[] pHash,
    //            String to, String txIndex, byte[] txid) {
    //        MIntTransactionInput mIntTx = buildTransaction(gHash, gPubKey, nHash, nonce, amount, pHash, to, txIndex, txid)
    //        return Utils.toURLBase64(hashTransactionMInt(mIntTx))
    //    }

        // txHash
        public func hashTransactionMint(_ mintTx: RenVM.MintTransactionInput) throws -> Data {
            var data = Data()
            let version = "1"
            let selector = "BTC/toSolana"
            data += marshal(src: version)
            data += marshal(src: selector)
            // marshalledType MintTransactionInput
            data += Base58
                .decode("aHQBEVgedhqiYDUtzYKdu1Qg1fc781PEV4D1gLsuzfpHNwH8yK2A2BuZK4uZoMC6pp8o7GWQxmsp52gsDrfbipkyeQZnXigCmscJY4aJDxF9tT8DQP3XRa1cBzQL8S8PTzi9nPnBkAxBhtNv6q1")
            data += marshal(src: Data(base64Encoded: mintTx.txid) ?? Data())
            
        }
    //    public static byte[] hashTransactionMInt(MIntTransactionInput mIntTx) {
    //        ByteArrayOutputStream out = ByteArrayOutputStream()
    //
    //        String version = "1"
    //        String selector = "BTC/toSolana"
    //        out.writeBytes(marshalString(version))
    //        out.writeBytes(marshalString(selector))
    //
    //        // marshalledType MIntTransactionInput
    //        out.writeBytes(Base58.decode(
    //                "aHQBEVgedhqiYDUtzYKdu1Qg1fc781PEV4D1gLsuzfpHNwH8yK2A2BuZK4uZoMC6pp8o7GWQxmsp52gsDrfbipkyeQZnXigCmscJY4aJDxF9tT8DQP3XRa1cBzQL8S8PTzi9nPnBkAxBhtNv6q1"))
    //
    //        out.writeBytes(marshalBytes(Utils.fromURLBase64(mIntTx.txid)))
    //        out.writeBytes(ByteUtils.uInt32ToByteArrayBE(Long.valueOf(mIntTx.txindex)))
    //        out.writeBytes(Utils.amountToUInt256ByteArrayBE(mIntTx.amount))
    //        out.writeBytes(byte[] { 0, 0, 0, 0 })
    //        out.writeBytes(Utils.fromURLBase64(mIntTx.phash))
    //        out.writeBytes(marshalString(mIntTx.to))
    //        out.writeBytes(Utils.fromURLBase64(mIntTx.nonce))
    //        out.writeBytes(Utils.fromURLBase64(mIntTx.nhash))
    //        out.writeBytes(marshalBytes(Utils.fromURLBase64(mIntTx.gpubkey)))
    //        out.writeBytes(Utils.fromURLBase64(mIntTx.ghash))
    //
    //        return Hash.sha256(out.toByteArray())
    //    }

    //    static byte[] marshalString(String src) {
    //        return marshalBytes(src.getBytes())
    //    }

    //    static byte[] marshalBytes(byte[] in) {
    //        byte[] out = byte[ByteUtils.UInt_32_LENGTH + in.length]
    //        System.arraycopy(ByteUtils.uInt32ToByteArrayBE(in.length), 0, out, 0, ByteUtils.UInt_32_LENGTH)
    //        System.arraycopy(in, 0, out, ByteUtils.UInt_32_LENGTH, in.length)
    //        return out
    //    }

    }
}

private func marshal(src: String) -> Data {
    marshal(src: Data(src.bytes))
}

private func marshal(src: Data) -> Data {
    
}
