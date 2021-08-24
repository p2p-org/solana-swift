//
//  SerumSwap+Slab.swift
//  SolanaSwift
//
//  Created by Chung Tran on 24/08/2021.
//

import Foundation
import BufferLayoutSwift

extension SerumSwap {
    struct Slab: BufferLayout {
        let header: SlabHeaderLayout
        let nodes: [SlabNodeLayout]
        init(buffer: Data, pointer: inout Int) throws {
            header = try .init(buffer: buffer, pointer: &pointer)
            
            var nodes = [SlabNodeLayout]()
            for _ in 0..<header.bumpIndex {
                nodes.append(
                    try SlabNodeLayout(buffer: buffer, pointer: &pointer)
                )
            }
            self.nodes = nodes
        }
        
        func serialize() throws -> Data {
            (try header.serialize()) + (try nodes.reduce(Data(), {$0 + (try $1.serialize())}))
        }
        
        func getNodeList(descending: Bool = false) -> LinkedList<SerumSwapSlabNodeLayoutType> {
            let list = LinkedList<SerumSwapSlabNodeLayoutType>()
            if header.leafCount == 0 {
                return list
            }
            var stack = [header.root]
            while stack.count > 0 {
                let index = stack.removeLast()
                guard let node = nodes[safe: Int(index)]?.value else {continue}
                switch node {
                case let leafNode as LeafNodeLayout:
                    list.append(leafNode)
                case let innerNode as InnerNodeLayout:
                    var nodeToAdd = [UInt32]()
                    if let child = innerNode.children[safe: 1] {
                        nodeToAdd.append(child)
                    }
                    if let child = innerNode.children[safe: 0] {
                        nodeToAdd.append(child)
                    }
                    if descending {nodeToAdd.reverse()}
                    stack += nodeToAdd
                default:
                    break
                }
            }
            return list
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
        
        static var length: Int {
            4 // tag
            + 68 // node
        }
        
        init(buffer: Data, pointer: inout Int) throws {
            guard buffer.count >= pointer + Self.length else {
                throw BufferLayoutSwift.Error.bytesLengthIsNotValid
            }
            self.tag = try UInt32(buffer: buffer, pointer: &pointer)
            switch tag {
            case 0:
                self.value = UninitializedNodeLayout()
            case 1:
                self.value = try InnerNodeLayout(buffer: buffer, pointer: &pointer)
            case 2:
                self.value = try LeafNodeLayout(buffer: buffer, pointer: &pointer)
            case 3:
                self.value = try FreeNodeLayout(buffer: buffer, pointer: &pointer)
            case 4:
                self.value = try LastFreeNodeLayout(buffer: buffer, pointer: &pointer)
            default:
                throw SerumSwapError("Unsupported node")
            }
        }
        
        func serialize() throws -> Data {
            var nodeData = Data()
            switch value {
            case is UninitializedNodeLayout:
                break
            case let value as InnerNodeLayout:
                nodeData += try value.serialize()
            case let value as LeafNodeLayout:
                nodeData += try value.serialize()
            case let value as FreeNodeLayout:
                nodeData += try value.serialize()
            case is LastFreeNodeLayout:
                break
            default:
                throw SerumSwapError("Unsupported node")
            }
            
            return tag.bytes + nodeData
        }
    }
    
    struct UninitializedNodeLayout: SerumSwapSlabNodeLayoutType {}
    
    struct InnerNodeLayout: SerumSwapSlabNodeLayoutType, BufferLayoutProperty {
        let prefixLen: UInt32
        let key: UInt128
        let children: [UInt32]
        static var length: Int {28}
        
        init(buffer: Data, pointer: inout Int) throws {
            guard buffer.count >= pointer + Self.length else {
                throw BufferLayoutSwift.Error.bytesLengthIsNotValid
            }
            self.prefixLen = try UInt32(buffer: buffer, pointer: &pointer)
            self.key = try UInt128(buffer: buffer, pointer: &pointer)
            self.children = [
                try UInt32(buffer: buffer, pointer: &pointer),
                try UInt32(buffer: buffer, pointer: &pointer)
            ]
        }
        
        func serialize() throws -> Data {
            Data() + (try prefixLen.serialize()) + (try key.serialize()) + (try children.reduce(Data(), {$0 + (try $1.serialize())}))
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
