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
        
        public var swapProgramId: PublicKey {
            switch self {
            case .mainnetBeta:
                return try! SolanaSDK.PublicKey(string: "SwaPpA9LAaLfeLi3a68M4DjnLqgtticKg6CnyNwgAC8")
            case .devnet:
                return try! SolanaSDK.PublicKey(string: "SwaPpA9LAaLfeLi3a68M4DjnLqgtticKg6CnyNwgAC8")
            case .testnet:
                return try! SolanaSDK.PublicKey(string: "SwaPpA9LAaLfeLi3a68M4DjnLqgtticKg6CnyNwgAC8")
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
