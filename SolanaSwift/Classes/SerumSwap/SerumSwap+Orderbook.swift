//
//  SerumSwap+Orderbook.swift
//  SolanaSwift
//
//  Created by Chung Tran on 20/08/2021.
//

import Foundation
import BufferLayoutSwift

extension SerumSwap {
    public struct Orderbook {
        
    }
}

extension SerumSwap.Orderbook {
    struct Layout: BufferLayout {
        let blob5: SerumSwap.Blob5
        let accountFlags: SerumSwap.AccountFlags
        let slab: Slab
        let blob7: SerumSwap.Blob7
    }
    
    struct Slab: BufferLayout {
        let header: SlabHeader
//        let nodes: SlabNodes
    }
    
    struct SlabHeader: BufferLayout {
        let bumpIndex: UInt32
        let zeros: UInt32
        let freeListLen: UInt32
        let zeros2: UInt32
        let freeListHead: UInt32
        let root: UInt32
        let leafCount: UInt32
        let zeros3: UInt32
    }
    
//    struct SlabNodes: BufferLayoutProperty {
//        static var numberOfNodes: Int {
//
//        }
//
//        static var numberOfBytes: Int {
//            numberOfNodes *
//        }
//
//        static func fromBytes(bytes: [UInt8]) throws -> SerumSwap.Orderbook.SlabNodes {
//            <#code#>
//        }
//
//        func encode() throws -> Data {
//            <#code#>
//        }
//    }
    
//    struct SlabNode: BufferLayoutProperty {
//        static var numberOfBytes: Int {
//            MemoryLayout<UInt32>.size // tag
//            + 68 // Node
//        }
//        
//        static func fromBytes(bytes: [UInt8]) throws -> SerumSwap.Orderbook.SlabNode {
//            // get tag
//            
//        }
//        
//        func encode() throws -> Data {
//            <#code#>
//        }
//        
//        let tag: UInt32
//    }
}
