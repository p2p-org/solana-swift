//
//  Network.swift
//  SolanaSwift
//
//  Created by Chung Tran on 26/01/2021.
//

import Foundation

extension SolanaSDK {
    public enum Network: String, CaseIterable {
        case mainnetBeta = "mainnet-beta"
        case devnet = "devnet"
        case testnet = "testnet"
        case localnet = "localnet"
        
        public var swapProgramId: PublicKey {
            switch self {
            case .mainnetBeta:
                return try! SolanaSDK.PublicKey(string: "9qvG1zUp8xF1Bi4m6UdRNby1BAAuaDrUxSpv4CmRRMjL")
            case .devnet:
                return try! SolanaSDK.PublicKey(string: "E7G3NKPwVcuPXjqL11J2ZZWBVRsocb6Lu3nK5BrRwBNd")
            case .testnet:
                return try! SolanaSDK.PublicKey(string: "FmgrCQX1JJSAkJEk8fiL85Cgnh7g3DS1rmakEjP1eCyL")
            default:
                fatalError("Unsupported network")
            }
        }
        
        public var cluster: String {rawValue}
        
        public var endpoint: String {
            // FIXME: - Remove later
            
            var string = cluster + ".solana.com"
            if self == .mainnetBeta {
//                string = "api." + string
                string = "solana-api.projectserum.com"
            }
            return "https://\(string)"
        }
    }
}
