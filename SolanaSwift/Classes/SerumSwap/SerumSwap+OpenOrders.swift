//
//  SerumSwap+OpenOrders.swift
//  SolanaSwift
//
//  Created by Chung Tran on 09/08/2021.
//

import Foundation
import BufferLayoutSwift

extension SolanaSDK.SerumSwap {
    class OpenOrders {
        
    }
    
    struct OpenOrdersLayoutV1: BufferLayout {
        let blob5: Blob5
        let accountFlags: AccountFlags
        let market: SolanaSDK.PublicKey
        let owner: SolanaSDK.PublicKey
        let baseTokenFree: UInt64
        let baseTokenTotal: UInt64
        let quoteTokenFree: UInt64
        let quoteTokenTotal: UInt64

        let freeSlotBits: UInt128
        let isBidBits: UInt128
        
//        seq(u128(), 128, 'orders'),
//          seq(u64(), 128, 'clientIds'),
        
        let blob7: Blob7
    }
    
    struct Blob5: BufferLayoutProperty {
        static var numberOfBytes: Int {5}
        
        static func fromBytes(bytes: [UInt8]) throws -> SolanaSDK.SerumSwap.Blob5 {
            Blob5()
        }
    }
    
    struct Blob7: BufferLayoutProperty {
        static var numberOfBytes: Int {7}
        
        static func fromBytes(bytes: [UInt8]) throws -> SolanaSDK.SerumSwap.Blob7 {
            Blob7()
        }
    }
    
    struct AccountFlags: BufferLayout, BufferLayoutProperty {
        private(set) var initialized: Bool
        private(set) var market: Bool
        private(set) var openOrders: Bool
        private(set) var requestQueue: Bool
        private(set) var eventQueue: Bool
        private(set) var bids: Bool
        private(set) var asks: Bool
        
        static var numberOfBytes: Int { 8 }
        
        static func fromBytes(bytes: [UInt8]) throws -> SolanaSDK.SerumSwap.AccountFlags {
            try .init(buffer: Data(bytes))
        }
    }
}
