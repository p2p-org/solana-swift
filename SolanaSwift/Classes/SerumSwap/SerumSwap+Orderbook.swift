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
    
    struct Slab {
        let header: SlabHeaderLayout
        let nodes: [SlabNodeLayout]
        init(buffer: Data) throws {
            let headerLength = try SlabHeaderLayout.getNumberOfBytes()
            guard buffer.count >= headerLength else {
                throw BufferLayoutSwift.Error.bytesLengthIsNotValid
            }
            header = try .init(buffer: buffer[0..<headerLength])
            
            var nodes = [SlabNodeLayout]()
            var pointer = headerLength
            for _ in 0..<header.bumpIndex {
                let endIndex = pointer + (try SlabNodeLayout.getNumberOfBytes())
                guard buffer.count >= endIndex else {
                    throw BufferLayoutSwift.Error.bytesLengthIsNotValid
                }
                let nodeData = Array(buffer[pointer..<endIndex])
                nodes.append(
                    try SlabNodeLayout(buffer: Data(nodeData))
                )
                pointer = endIndex
            }
            self.nodes = nodes
        }
        
//        func get(_ searchKey: BInt) throws -> SerumSwapSlabNodeLayoutType? {
//            guard header.leafCount > 0 else {return nil}
//            let index = header.root
//            while true {
//                guard let node = nodes[safe: Int(index)] else {
//                    return nil
//                }
//                switch node.value {
//                case let node as LeafNodeLayout:
//                    if BInt(node.key) == searchKey {
//                        return node
//                    }
//                    return nil
//                case let node as InnerNodeLayout:
//                    let xor = BInt(node.key) ^ searchKey
//                    let iushrn =
//                default:
//                    throw SerumSwapError("Invalid slab")
//                }
//            }
//        }
    }
}

extension SerumSwap.Orderbook {
    struct Layout: BufferLayout {
        let blob5: SerumSwap.Blob5
        let accountFlags: SerumSwap.AccountFlags
        let slab: SerumSwap.Slab
    }
}

extension SerumSwap {
    struct SlabHeaderLayout: BufferLayout {
        let bumpIndex: UInt32
        let zeros: UInt32
        let freeListLen: UInt32
        let zeros2: UInt32
        let freeListHead: UInt32
        let root: UInt32
        let leafCount: UInt32
        let zeros3: UInt32
    }

    struct SlabNodeLayout: BufferLayoutProperty {
        let tag: UInt32
        let value: SerumSwapSlabNodeLayoutType
        
        static func getNumberOfBytes() throws -> Int {
            4 // tag
            + 68 // node
        }
        
        init(buffer: Data) throws {
            guard buffer.count >= (try Self.getNumberOfBytes()) else {
                throw BufferLayoutSwift.Error.bytesLengthIsNotValid
            }
            self.tag = try UInt32(buffer: buffer[0..<4])
            
            let buffer = Data(Array(buffer[4...]))
            switch tag {
            case 0:
                self.value = UninitializedNodeLayout()
            case 1:
                self.value = try InnerNodeLayout(buffer: buffer)
            case 2:
                self.value = try LeafNodeLayout(buffer: buffer)
            case 3:
                self.value = try FreeNodeLayout(buffer: buffer)
            case 4:
                self.value = try LastFreeNodeLayout(buffer: buffer)
            default:
                throw SerumSwapError("Unsupported node")
            }
        }
        
        func encode() throws -> Data {
            var data = Data(tag.bytes)
            
            var nodeData = Data()
            switch value {
            case is UninitializedNodeLayout:
                break
            case let value as InnerNodeLayout:
                nodeData += try value.encode()
            case let value as LeafNodeLayout:
                nodeData += try value.encode()
            case let value as FreeNodeLayout:
                nodeData += try value.encode()
            case is LastFreeNodeLayout:
                break
            default:
                throw SerumSwapError("Unsupported node")
            }
            data += nodeData
            
            let zeros = [UInt8](repeating: 0, count: (try Self.getNumberOfBytes())-4-nodeData.count)
            return data + zeros
        }
    }
    
    struct UninitializedNodeLayout: SerumSwapSlabNodeLayoutType {}
    
    struct InnerNodeLayout: SerumSwapSlabNodeLayoutType, BufferLayoutProperty {
        let prefixLen: UInt32
        let key: UInt128
        let children: [UInt32]
        static func getNumberOfBytes() throws -> Int {
            4+16+4+4
        }
        
        init(buffer: Data) throws {
            guard buffer.count >= 28 else {
                throw BufferLayoutSwift.Error.bytesLengthIsNotValid
            }
            self.prefixLen = try UInt32(buffer: buffer[0..<4])
            self.key = try UInt128(buffer: buffer[4..<20])
            self.children = [
                try UInt32(buffer: buffer[20..<24]),
                try UInt32(buffer: buffer[24..<28])
            ]
        }
        
        func encode() throws -> Data {
            Data() + (try prefixLen.encode()) + (try key.encode()) + (try children.reduce(Data(), {$0 + (try $1.encode())}))
        }
    }
    
    struct LeafNodeLayout: SerumSwapSlabNodeLayoutType, BufferLayout {
        let ownerSlot: UInt8
        let feeTier: UInt8
        let blob2: SerumSwap.Blob2
        let key: UInt128
        let owner: SerumSwap.PublicKey
        let quantity: UInt64
        let clientOrderId: UInt64
    }
    
    struct FreeNodeLayout: SerumSwapSlabNodeLayoutType, BufferLayout {
        let next: UInt32
    }
    
    struct LastFreeNodeLayout: SerumSwapSlabNodeLayoutType, BufferLayout {}
}

protocol SerumSwapSlabNodeLayoutType {}

//extension BInt {
//    func iushrn(bits: BInt, hint: BInt) {
//        let r = bits % 26
//        let s = (bits - r) / 26
//        var carryMask: UInt = UInt((0x3ffffff >>> (26 - Int(r))) << (26 - r))
//
//
//        var words = self.words
////        let i
//        if r != 0 {
//            var carry = 0
//            for i in 0..<self.bitWidth {
//                var newCarry = words[i] & carryMask
//                let c = ((words[i] | 0) - newCarry) << r
//                words[i] = c | UInt(carry)
//                carry = newCarry >>> 26 - Int(r)
//            }
//            if ((carry) != 0) {
//                words[i] = carry
//
//            }
//        }
//    }
//}
