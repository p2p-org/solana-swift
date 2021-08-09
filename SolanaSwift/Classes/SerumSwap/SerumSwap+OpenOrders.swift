//
//  SerumSwap+OpenOrders.swift
//  SolanaSwift
//
//  Created by Chung Tran on 09/08/2021.
//

import Foundation
import BufferLayoutSwift

extension SolanaSDK.SerumSwap {
    public class OpenOrders {
        
    }
}

// MARK: - Models
public extension SolanaSDK.SerumSwap {
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
        
        let orders: Seq128Elements<UInt128>
        let clientIds: Seq128Elements<UInt64>
        
        let blob7: Blob7
    }
    
    struct OpenOrdersLayoutV2: BufferLayout {
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
        
        let referrerRebatesAccrued: UInt64
        
        let blob7: Blob7
    }
    
    struct Blob5: BufferLayoutProperty {
        public static var numberOfBytes: Int {5}
        
        public static func fromBytes(bytes: [UInt8]) throws -> SolanaSDK.SerumSwap.Blob5 {
            Blob5()
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
        
        public static var numberOfBytes: Int { 8 }
        
        public static func fromBytes(bytes: [UInt8]) throws -> SolanaSDK.SerumSwap.AccountFlags {
            try .init(buffer: Data(bytes))
        }
    }
    
    struct Seq128Elements<T: FixedWidthInteger>: BufferLayoutProperty {
        var elements: [T]
        
        public static var numberOfBytes: Int {
            128 * MemoryLayout<T>.size
        }
        
        public static func fromBytes(bytes: [UInt8]) throws -> SolanaSDK.SerumSwap.Seq128Elements<T> {
            guard bytes.count > Self.numberOfBytes else {
                throw BufferLayoutSwift.Error.bytesLengthIsNotValid
            }
            var elements = [T]()
            let chunkedArray = bytes.chunked(into: MemoryLayout<T>.size)
            for element in chunkedArray {
                let data = Data(element)
                let num = T(littleEndian: data.withUnsafeBytes { $0.load(as: T.self) })
                elements.append(num)
            }
            return .init(elements: elements)
        }
    }
    
    struct Blob7: BufferLayoutProperty {
        public static var numberOfBytes: Int {7}
        
        public static func fromBytes(bytes: [UInt8]) throws -> SolanaSDK.SerumSwap.Blob7 {
            Blob7()
        }
    }
}

private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
