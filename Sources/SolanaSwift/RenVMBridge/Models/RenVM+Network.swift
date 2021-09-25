//
//  RenVM+Network.swift
//  Alamofire
//
//  Created by Chung Tran on 09/09/2021.
//

import Foundation

extension RenVM {
    public struct Network {
        public private(set) var chain: String
        public private(set) var endpoint: String
        public private(set) var lightNode: String
        public private(set) var gatewayRegistry: String
        public private(set) var genesisHash: String
        public private(set) var p2shPrefix: UInt8
        
        public static var mainnet: Self {
            .init(
                chain: "mainnet",
                endpoint: "https://ren.rpcpool.com/",
                lightNode: "https://lightnode-mainnet.herokuapp.com",
                gatewayRegistry: "REGrPFKQhRneFFdUV3e9UDdzqUJyS6SKj88GdXFCRd2",
                genesisHash: "5eykt4UsFv8P8NJdTREpY1vzqKqZKvdpKuc147dw2N9d",
                p2shPrefix: 0x05
            )
        }
        
        public static var testnet: Self {
            .init(
                chain: "testnet",
                endpoint: "https://api.devnet.solana.com",
                lightNode: "https://lightnode-testnet.herokuapp.com/",
                gatewayRegistry: "REGrPFKQhRneFFdUV3e9UDdzqUJyS6SKj88GdXFCRd2",
                genesisHash: "EtWTRABZaYq6iMfeYKouRu166VU2xqa1wcaWoxPkrZBG",
                p2shPrefix: 0xc4
            )
        }
        
        public static var devnet: Self {
            .init(
                chain: "devnet",
                endpoint: "https://api.testnet.solana.com",
                lightNode: "https://lightnode-devnet.herokuapp.com",
                gatewayRegistry: "REGrPFKQhRneFFdUV3e9UDdzqUJyS6SKj88GdXFCRd2",
                genesisHash: "4uhcVJyU9pJkvQyS88uRDiswHXSCkY3zQawwpjk2NsNY",
                p2shPrefix: 0xc4
            )
        }
        
        public var isTestnet: Bool {
            chain != "mainnet"
        }
    }
}

