//
//  SerumSwap+OpenOrders.swift
//  SolanaSwift
//
//  Created by Chung Tran on 09/08/2021.
//

import Foundation
import BufferLayoutSwift
import RxSwift

private var PROGRAM_LAYOUT_VERSIONS: [String: Int] { [
    "4ckmDgGdxQoPDLUkDT3vHgSAkzA3QRdNq5ywwY4sUSJn": 1,
    "BJ3jrUzddfuSrZHXSCxMUUQsjKEyLmuuyZebkcaFp2fg": 1,
    "EUqojwWA2rd19FZrzeBncJsm38Jm1hEhE3zsmX3bRc2o": 2,
    "9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin": 3
] }

extension SerumSwap {
    public class OpenOrders {
        let address: PublicKey
        let data: SerumSwapOpenOrdersLayoutType
        let programId: PublicKey
        let version: Int
        
        init(
            address: PublicKey,
            data: SerumSwapOpenOrdersLayoutType,
            programId: PublicKey
        ) throws {
            self.address = address
            self.programId = programId
            self.version = PROGRAM_LAYOUT_VERSIONS[programId.base58EncodedString] ?? 3
            if !data.accountFlags.initialized || !data.accountFlags.openOrders
            {
                throw SerumSwapError.invalidOpenOrdersAccount
            }
            self.data = data
        }
        
        static func findForOwner(
            client: OpenOrdersAPIClient,
            ownerAddress: PublicKey,
            programId: PublicKey
        ) -> Single<[OpenOrders]> {
            
            let memcmp = SolanaSDK.EncodableWrapper(
                wrapped: [
                    "offset": SolanaSDK.EncodableWrapper(wrapped: PublicKey.numberOfBytes),
                     "bytes": SolanaSDK.EncodableWrapper(wrapped: ownerAddress.base58EncodedString)
                ]
            )
            
            return getFilteredProgramAccounts(
                client: client,
                ownerAddress: ownerAddress,
                filter: [["memcmp": memcmp]],
                programId: programId
            )
        }
        
        static func findForMarketAndOwner(
            client: OpenOrdersAPIClient,
            marketAddress: PublicKey,
            ownerAddress: PublicKey,
            programId: PublicKey
        ) -> Single<[OpenOrders]> {
            let memcmp1 = SolanaSDK.EncodableWrapper(
                wrapped: [
                    "offset": SolanaSDK.EncodableWrapper(wrapped: PublicKey.numberOfBytes),
                     "bytes": SolanaSDK.EncodableWrapper(wrapped: marketAddress.base58EncodedString)
                ]
            )
            
            let memcmp2 = SolanaSDK.EncodableWrapper(
                wrapped: [
                    "offset": SolanaSDK.EncodableWrapper(wrapped: PublicKey.numberOfBytes),
                     "bytes": SolanaSDK.EncodableWrapper(wrapped: ownerAddress.base58EncodedString)
                ]
            )
            
            return getFilteredProgramAccounts(
                client: client,
                ownerAddress: ownerAddress,
                filter: [
                    ["memcmp": memcmp1],
                    ["memcmp": memcmp2]
                ],
                programId: programId
            )
        }
        
        
        private static func getFilteredProgramAccounts(
            client: OpenOrdersAPIClient,
            ownerAddress: PublicKey,
            filter: [[String: SolanaSDK.EncodableWrapper]],
            programId: PublicKey
        ) -> Single<[OpenOrders]> {
            var filter = filter
            let version = PROGRAM_LAYOUT_VERSIONS[programId.base58EncodedString] ?? 3
            if version == 1 {
                filter.append(["dataSize": .init(wrapped: try! OpenOrdersLayoutV1.getBufferLength())])
                return client.getProgramAccounts(
                    publicKey: programId.base58EncodedString,
                    configs: .init(filters: filter),
                    decodedTo: OpenOrdersLayoutV1.self
                )
                .map {
                    try $0.accounts.map {
                        guard $0.account.owner == programId.base58EncodedString else {
                            throw SerumSwapError.addressIsNotOwnedByTheProgram
                        }
                        return try OpenOrders(
                            address: ownerAddress,
                            data: $0.account.data,
                            programId: programId
                        )
                    }
                }
            }
            
            filter.append(["dataSize": .init(wrapped: try! OpenOrdersLayoutV2.getBufferLength())])
            return client.getProgramAccounts(
                publicKey: programId.base58EncodedString,
                configs: .init(filters: filter),
                decodedTo: OpenOrdersLayoutV2.self
            )
            .map {
                try $0.accounts.map {
                    guard $0.account.owner == programId.base58EncodedString else {
                        throw SerumSwapError.addressIsNotOwnedByTheProgram
                    }
                    return try OpenOrders(
                        address: ownerAddress,
                        data: $0.account.data,
                        programId: programId
                    )
                }
            }
        }
    }
}

// MARK: - Models
public protocol SerumSwapOpenOrdersLayoutType {
    var blob5: Blob5 {get}
    var accountFlags: AccountFlags {get}
    var market: SolanaSDK.PublicKey {get}
    var owner: SolanaSDK.PublicKey {get}
    var baseTokenFree: UInt64 {get}
    var baseTokenTotal: UInt64 {get}
    var quoteTokenFree: UInt64 {get}
    var quoteTokenTotal: UInt64 {get}
    var freeSlotBits: UInt128 {get}
    var isBidBits: UInt128 {get}
    var orders: Seq128Elements<UInt128> {get}
    var clientIds: Seq128Elements<UInt64> {get}
    var blob7: Blob7 {get}
}

public protocol OpenOrdersLayoutType {}

struct OpenOrdersLayoutV1: SerumSwapOpenOrdersLayoutType, DecodableBufferLayout {
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

struct OpenOrdersLayoutV2: SerumSwapOpenOrdersLayoutType, DecodableBufferLayout {
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
    
    let referrerRebatesAccrued: UInt64
    
    let blob7: Blob7
}

public struct Blob5: BufferLayoutProperty {
    public static var numberOfBytes: Int {5}
    
    public static func fromBytes(bytes: [UInt8]) throws -> Blob5 {
        Blob5()
    }
}

public struct AccountFlags: BufferLayout, BufferLayoutProperty {
    private(set) var initialized: Bool
    private(set) var market: Bool
    private(set) var openOrders: Bool
    private(set) var requestQueue: Bool
    private(set) var eventQueue: Bool
    private(set) var bids: Bool
    private(set) var asks: Bool
    
    public static var numberOfBytes: Int { 8 }
    
    public static func fromBytes(bytes: [UInt8]) throws -> AccountFlags {
        try .init(buffer: Data(bytes))
    }
}

public struct Seq128Elements<T: FixedWidthInteger>: BufferLayoutProperty {
    var elements: [T]
    
    public static var numberOfBytes: Int {
        128 * MemoryLayout<T>.size
    }
    
    public static func fromBytes(bytes: [UInt8]) throws -> Seq128Elements<T> {
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

public struct Blob7: BufferLayoutProperty {
    public static var numberOfBytes: Int {7}
    
    public static func fromBytes(bytes: [UInt8]) throws -> Blob7 {
        Blob7()
    }
}

private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
