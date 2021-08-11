//
//  SerumSwap+OpenOrders.swift
//  SolanaSwift
//
//  Created by Chung Tran on 09/08/2021.
//

import Foundation
import BufferLayoutSwift
import RxSwift

extension SerumSwap {
    public struct OpenOrders {
        let address: PublicKey
        let data: SerumSwapOpenOrdersLayoutType
        let programId: PublicKey
        let version: Int
        
        var publicKey: PublicKey {address}
        
        init(
            address: PublicKey,
            data: SerumSwapOpenOrdersLayoutType,
            programId: PublicKey
        ) throws {
            self.address = address
            self.programId = programId
            self.version = getVersion(programId: programId.base58EncodedString)
            if !data.accountFlags.initialized || !data.accountFlags.openOrders
            {
                throw SerumSwapError("Invalid OpenOrders account")
            }
            self.data = data
        }
        
        private static func getLayoutType(programId: String) -> SerumSwapOpenOrdersLayoutType.Type {
            let version = SerumSwap.getVersion(programId: programId)
            if version == 1 {return OpenOrdersLayoutV1.self}
            return OpenOrdersLayoutV2.self
        }

        private static func getLayoutSpan(programId: String) -> UInt64 {
            getLayoutType(programId: programId).span
        }
        
        static func findForOwner(
            client: SerumSwapAPIClient,
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
            client: SerumSwapAPIClient,
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
        
        static func makeCreateAccountInstruction(
            client: SerumSwapAPIClient,
            marketAddress: PublicKey,
            ownerAddress: PublicKey,
            newAccountAddress: PublicKey,
            programId: PublicKey
        ) -> Single<TransactionInstruction> {
            let span = getLayoutSpan(programId: programId.base58EncodedString)
            return client.getMinimumBalanceForRentExemption(span: span)
                .map {minRentExemption in
                    SystemProgram.createAccountInstruction(
                        from: ownerAddress,
                        toNewPubkey: newAccountAddress,
                        lamports: minRentExemption,
                        space: span,
                        programPubkey: programId
                    )
                }
        }
        
        private static func getFilteredProgramAccounts(
            client: SerumSwapAPIClient,
            ownerAddress: PublicKey,
            filter: [[String: SolanaSDK.EncodableWrapper]],
            programId: PublicKey
        ) -> Single<[OpenOrders]> {
            var filter = filter
            filter.append(["dataSize": .init(wrapped: getLayoutSpan(programId: programId.base58EncodedString))])
            
            let version = getVersion(programId: programId.base58EncodedString)
            
            if version == 1 {
                return client.getProgramAccounts(
                    publicKey: programId.base58EncodedString,
                    configs: .init(filters: filter),
                    decodedTo: OpenOrdersLayoutV1.self
                )
                .map {
                    try $0.accounts.map {
                        guard $0.account.owner == programId.base58EncodedString else {
                            throw SerumSwapError("The address is not owned by the program")
                        }
                        return try OpenOrders(
                            address: ownerAddress,
                            data: $0.account.data,
                            programId: programId
                        )
                    }
                }
            }
            
            return client.getProgramAccounts(
                publicKey: programId.base58EncodedString,
                configs: .init(filters: filter),
                decodedTo: OpenOrdersLayoutV2.self
            )
            .map {
                try $0.accounts.map {
                    guard $0.account.owner == programId.base58EncodedString else {
                        throw SerumSwapError("The address is not owned by the program")
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
    static var span: UInt64 {get}
    var blob5: SerumSwap.Blob5 {get}
    var accountFlags: SerumSwap.AccountFlags {get}
    var market: SolanaSDK.PublicKey {get}
    var owner: SolanaSDK.PublicKey {get}
    var baseTokenFree: UInt64 {get}
    var baseTokenTotal: UInt64 {get}
    var quoteTokenFree: UInt64 {get}
    var quoteTokenTotal: UInt64 {get}
    var freeSlotBits: UInt128 {get}
    var isBidBits: UInt128 {get}
    var orders: SerumSwap.Seq128Elements<UInt128> {get}
    var clientIds: SerumSwap.Seq128Elements<UInt64> {get}
    var blob7: SerumSwap.Blob7 {get}
}

extension SerumSwap {
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
}

