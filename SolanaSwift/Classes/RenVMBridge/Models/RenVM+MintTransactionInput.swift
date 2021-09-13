//
//  MintTransactionInput.swift
//  SolanaSwift
//
//  Created by Chung Tran on 13/09/2021.
//

import Foundation

extension RenVM {
    struct MintTransactionInput: Encodable {
        init(txid: String, txindex: String, ghash: String, gpubkey: String, nhash: String, nonce: String, payload: String, phash: String, to: String, amount: String) {
            self.txid = txid
            self.txindex = txindex
            self.ghash = ghash
            self.gpubkey = gpubkey
            self.nhash = nhash
            self.nonce = nonce
            self.payload = payload
            self.phash = phash
            self.to = to
            self.amount = amount
        }
        
        init(
            gHash: Data,
            gPubkey: Data,
            nHash: Data,
            nonce: Data,
            amount: String,
            pHash: Data,
            to: String,
            txIndex: String,
            txid: Data
        ) {
            self.txid       = txid.base64urlEncodedString()
            self.txindex    = txIndex
            self.ghash      = gHash.base64urlEncodedString()
            self.gpubkey    = gPubkey.base64urlEncodedString()
            self.nhash      = nHash.base64urlEncodedString()
            self.nonce      = nonce.base64urlEncodedString()
            self.payload    = ""
            self.phash      = pHash.base64urlEncodedString()
            self.to         = to
            self.amount     = amount
        }
        
        let txid: String
        let txindex: String
        let ghash: String
        let gpubkey: String
        let nhash: String
        let nonce: String
        let payload: String
        let phash: String
        let to: String
        let amount: String
        
        func hash(selector: String, version: String) throws -> Data {
            var data = Data()
            let version = "1"
            let selector = "BTC/toSolana"
            data += marshal(src: version)
            data += marshal(src: selector)
            // marshalledType MintTransactionInput
            data += Base58
                .decode("aHQBEVgedhqiYDUtzYKdu1Qg1fc781PEV4D1gLsuzfpHNwH8yK2A2BuZK4uZoMC6pp8o7GWQxmsp52gsDrfbipkyeQZnXigCmscJY4aJDxF9tT8DQP3XRa1cBzQL8S8PTzi9nPnBkAxBhtNv6q1")
            
            data += marshal(src: try txid.base64UrlEncoded())
            data += try txindex.uint32Data()
            data += try serializeAmount(amount)
            data += [UInt8](repeating: 0, count: 4)
            data += try phash.base64UrlEncoded()
            data += marshal(src: to)
            data += try nonce.base64UrlEncoded()
            data += try nhash.base64UrlEncoded()
            data += marshal(src: try gpubkey.base64UrlEncoded())
            data += try ghash.base64UrlEncoded()
            return data.sha256()
        }
    }
}

private extension String {
    func base64UrlEncoded() throws -> Data {
        guard let data = Data(base64urlEncoded: self)
        else {
            throw RenVM.Error("Base64 encoded string is not valid")
        }
        return data
    }
    
    func uint32Data() throws -> Data {
        guard let num = UInt32(self)?.bytesWithBigEndian
        else {
            throw RenVM.Error("Not an UInt32")
        }
        return Data(num)
    }
}

private func marshal(src: String) -> Data {
    marshal(src: Data(src.bytes))
}

private func marshal(src: Data) -> Data {
    var data = Data()
    data += UInt32(src.count).bytesWithBigEndian
    data += src
    return data
}

private func serializeAmount(_ amount: String) throws -> [UInt8] {
    guard let amount = UInt256(amount) else {
        throw RenVM.Error("Amount is not valid")
    }
    var bigEndian = amount.bigEndian
    return withUnsafeBytes(of: &bigEndian, {Array($0)})
}
