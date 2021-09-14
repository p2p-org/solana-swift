//
//  RenVM+Hash.swift
//  SolanaSwift
//
//  Created by Chung Tran on 09/09/2021.
//

import Foundation
import CryptoSwift

extension RenVM {
    struct Hash {
        static func generatePHash() -> Data {
            Data([UInt8]().keccak256)
        }
        
        static func generateSHash(selector: Selector) -> Data {
            Data(selector.toString().keccak256)
        }
        
        static func generateGHash(
            to: String,
            tokenIdentifier: String,
            nonce: [UInt8]
        ) -> Data {
            let pHash = generatePHash()
            let sHash = Data(hex: tokenIdentifier)
            let toBytes = Data(hex: to)
            
            var data = Data()
            data += pHash
            data += sHash
            data += toBytes
            data += nonce
            
            return data.keccak256
        }
        
        static func generateNHash(
            nonce: [UInt8],
            txId: [UInt8],
            txIndex: UInt32
        ) -> Data {
            var data = Data()
            data += nonce + txId + txIndex.bytes
            return data.keccak256
        }
    }
}

extension Data {
    var hash160: Data {
        ask_BTCHash160()
    }
    
    var keccak256: Data {
        sha3(.keccak256)
    }
    
    public init?(base64urlEncoded input: String) {
        var base64 = input
        base64 = base64.replacingOccurrences(of: "-", with: "+")
        base64 = base64.replacingOccurrences(of: "_", with: "/")
        while base64.count % 4 != 0 {
            base64 = base64.appending("=")
        }
        self.init(base64Encoded: base64)
    }
    
    public func base64urlEncodedString() -> String {
        var result = self.base64EncodedString()
        result = result.replacingOccurrences(of: "+", with: "-")
        result = result.replacingOccurrences(of: "/", with: "_")
        result = result.replacingOccurrences(of: "=", with: "")
        return result
    }
    
    private var secp256k1nHEX: String {
        "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141".lowercased();
    }
    
    private var secp256k1n: BInt {
        BInt(hex: secp256k1nHEX)
    }
    
    func fixSignatureSimple() throws -> Data {
        guard self.count > 64
        else {throw RenVM.Error("Signature is not valid")}
        
        let r = Data(self[0..<32])
        let s = Data(self[32..<64])
        let v = self[64] % 27
        
        var sBN = BInt(data: s)
        var vFixed: UInt8 = (v % 27) + 27
        
        // FIXME
        if sBN > (secp256k1n / 2) {
            sBN = secp256k1n - sBN
            vFixed = v == 27 ? 28: 27
        }
        
        return r + sBN.data + [vFixed]
    }
}

extension Array where Element == UInt8 {
    var keccak256: Self {
        sha3(.keccak256)
    }
}

extension String {
    var keccak256: [UInt8] {
        bytes.keccak256
    }
    
    func decodeBase64URL() -> Data? {
        Data(base64urlEncoded: self)
    }
}

extension UInt64 {
    
}
