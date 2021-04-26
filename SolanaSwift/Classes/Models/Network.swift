//
//  Network.swift
//  SolanaSwift
//
//  Created by Chung Tran on 26/01/2021.
//

import Foundation

extension SolanaSDK {
    public enum Network: String, CaseIterable, Codable {
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
    }
}
