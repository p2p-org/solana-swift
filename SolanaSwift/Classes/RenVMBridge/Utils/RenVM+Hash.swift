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
        
        static func generateSHash() -> Data {
            Data("BTC/toSolana".keccak256)
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
}
