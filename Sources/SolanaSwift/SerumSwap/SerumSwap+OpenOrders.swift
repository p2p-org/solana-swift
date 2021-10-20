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
            address: String,
            data: SerumSwapOpenOrdersLayoutType,
            programId: PublicKey
        ) throws {
            self.address = try PublicKey(string: address)
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
            if version == 1 {return LayoutV1.self}
            return LayoutV2.self
        }

        private static func getLayoutSpan(programId: String) -> UInt64 {
            getLayoutType(programId: programId).span
        }
        
        static func makeCreateAccountInstructions(
            client: SerumSwapAPIClient,
            marketAddress: PublicKey,
            ownerAddress: PublicKey,
            programId: PublicKey,
            minRentExemption: UInt64? = nil,
            shouldInitAccount: Bool,
            closeAfterward: Bool
        ) -> Single<AccountInstructions> {
            let requestMinRentExemption: Single<UInt64>
            if let minRentExemption = minRentExemption {
                requestMinRentExemption = .just(minRentExemption)
            } else {
                requestMinRentExemption = Self.getMinimumBalanceForRentExemption(
                    client: client,
                    programId: programId
                )
            }
            
            let requestNewAccount = Single<Account>.create { observer in
                DispatchQueue(label: "create account", qos: .userInteractive)
                    .async {
                        do {
                            let newAccount = try Account(network: .mainnetBeta)
                            observer(.success(newAccount))
                        } catch {
                            observer(.failure(error))
                        }
                    }
                return Disposables.create()
            }
            
            return Single.zip(
                requestMinRentExemption,
                requestNewAccount
            )
                .map {minRentExemption, order in
                    var instructions = [
                        SystemProgram.createAccountInstruction(
                            from: ownerAddress,
                            toNewPubkey: order.publicKey,
                            lamports: minRentExemption,
                            space: getLayoutSpan(programId: programId.base58EncodedString),
                            programPubkey: programId
                        )
                    ]
                    
                    if shouldInitAccount {
                        instructions.append (
                            initOrderInstruction(
                                order: order.publicKey,
                                marketAddress: marketAddress,
                                owner: ownerAddress
                            )
                        )
                    }
                    
                    var cleanupInstructions = [TransactionInstruction]()
                    if closeAfterward {
                        cleanupInstructions.append(
                            closeOrderInstruction(
                                order: order.publicKey,
                                marketAddress: marketAddress,
                                owner: ownerAddress,
                                destination: ownerAddress
                            )
                        )
                    }
                    
                    return .init(
                        account: order.publicKey,
                        instructions: instructions,
                        cleanupInstructions: cleanupInstructions,
                        signers: [order]
                    )
                }
        }
        
        static func getMinimumBalanceForRentExemption(
            client: SerumSwapAPIClient,
            programId: PublicKey
        ) -> Single<UInt64> {
            let span = getLayoutSpan(programId: programId.base58EncodedString)
            return client.getMinimumBalanceForRentExemption(span: span)
        }
        
        public static func findForOwner(
            client: SerumSwapAPIClient,
            ownerAddress: PublicKey,
            programId: PublicKey = .dexPID
        ) -> Single<[OpenOrders]> {
            
            let memcmp = EncodableWrapper(
                wrapped: [
                    "offset": EncodableWrapper(wrapped: 45),
                     "bytes": EncodableWrapper(wrapped: ownerAddress.base58EncodedString)
                ]
            )
            
            return getFilteredProgramAccounts(
                client: client,
                ownerAddress: ownerAddress,
                filter: [["memcmp": memcmp]],
                programId: programId
            )
        }
        
        // MARK: - Old
        static func findForMarketAndOwner(
            client: SerumSwapAPIClient,
            marketAddress: PublicKey,
            ownerAddress: PublicKey,
            programId: PublicKey = .dexPID
        ) -> Single<[OpenOrders]> {
            let memcmp1 = EncodableWrapper(
                wrapped: [
                    "offset": EncodableWrapper(wrapped: 45),
                     "bytes": EncodableWrapper(wrapped: marketAddress.base58EncodedString)
                ]
            )
            
            let memcmp2 = EncodableWrapper(
                wrapped: [
                    "offset": EncodableWrapper(wrapped: 45),
                     "bytes": EncodableWrapper(wrapped: ownerAddress.base58EncodedString)
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
            client: SerumSwapAPIClient,
            ownerAddress: PublicKey,
            filter: [[String: EncodableWrapper]],
            programId: PublicKey
        ) -> Single<[OpenOrders]> {
            var filter = filter
            filter.append(["dataSize": .init(wrapped: getLayoutSpan(programId: programId.base58EncodedString))])
            
            let version = getVersion(programId: programId.base58EncodedString)
            
            if version == 1 {
                return client.getProgramAccounts(
                    publicKey: programId.base58EncodedString,
                    configs: .init(filters: filter),
                    decodedTo: LayoutV1.self,
                    log: false
                )
                .map {
                    try $0.accounts.map {
                        guard $0.account.owner == programId.base58EncodedString else {
                            throw SerumSwapError("The address is not owned by the program")
                        }
                        return try OpenOrders(
                            address: $0.pubkey,
                            data: $0.account.data,
                            programId: programId
                        )
                    }
                }
            }
            
            return client.getProgramAccounts(
                publicKey: programId.base58EncodedString,
                configs: .init(encoding: "base64", filters: filter),
                decodedTo: LayoutV2.self,
                log: false
            )
            .map {
                try $0.accounts.map {
                    guard $0.account.owner == programId.base58EncodedString else {
                        throw SerumSwapError("The address is not owned by the program")
                    }
                    return try OpenOrders(
                        address: $0.pubkey,
                        data: $0.account.data,
                        programId: programId
                    )
                }
            }
        }
        static func findAnOpenOrderOrCreateOne(
            client: SerumSwapAPIClient,
            marketAddress: PublicKey,
            ownerAddress: PublicKey,
            programId: PublicKey = .dexPID,
            minRentExemption: UInt64? = nil
        ) -> Single<GetOpenOrderResult> {
            fatalError()
//            findForMarketAndOwner(
//                client: client,
//                marketAddress: marketAddress,
//                ownerAddress: ownerAddress,
//                programId: programId
//            )
//            .map {$0.first?.address}
//            .flatMap { openOrder in
//                if let openOrder = openOrder {
//                    return .just((existingOpenOrder: openOrder, newOpenOrder: nil))
//                }
//                let newOpenOrder = try Account(network: .mainnetBeta)
//                return makeCreateAccountInstruction(
//                    client: client,
//                    marketAddress: marketAddress,
//                    ownerAddress: ownerAddress,
//                    newAccountAddress: newOpenOrder.publicKey,
//                    programId: programId,
//                    minRentExemption: minRentExemption
//                )
//                    .map {(
//                        existingOpenOrder: nil,
//                        newOpenOrder: .init(
//                            signers: [newOpenOrder],
//                            instructions: [$0]
//                        )
//                    )}
//            }
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

extension SerumSwap.OpenOrders {
    struct LayoutV1: SerumSwapOpenOrdersLayoutType, DecodableBufferLayout {
        static var span: UInt64 {
            UInt64(141) +
            UInt64(SerumSwap.Seq128Elements<UInt128>.length) +
            UInt64(SerumSwap.Seq128Elements<UInt64>.length) +
            UInt64(7)
        }
        let blob5: SerumSwap.Blob5
        let accountFlags: SerumSwap.AccountFlags
        let market: SolanaSDK.PublicKey
        let owner: SolanaSDK.PublicKey
        let baseTokenFree: UInt64
        let baseTokenTotal: UInt64
        let quoteTokenFree: UInt64
        let quoteTokenTotal: UInt64

        let freeSlotBits: UInt128
        let isBidBits: UInt128
        
        let orders: SerumSwap.Seq128Elements<UInt128>
        let clientIds: SerumSwap.Seq128Elements<UInt64>
        
        let blob7: SerumSwap.Blob7
    }

    struct LayoutV2: SerumSwapOpenOrdersLayoutType, DecodableBufferLayout {
        static var span: UInt64 {LayoutV1.span + 8}
        
        let blob5: SerumSwap.Blob5
        let accountFlags: SerumSwap.AccountFlags
        let market: SolanaSDK.PublicKey
        let owner: SolanaSDK.PublicKey
        let baseTokenFree: UInt64
        let baseTokenTotal: UInt64
        let quoteTokenFree: UInt64
        let quoteTokenTotal: UInt64
        
        let freeSlotBits: UInt128
        let isBidBits: UInt128
        
        let orders: SerumSwap.Seq128Elements<UInt128>
        let clientIds: SerumSwap.Seq128Elements<UInt64>
        
        let referrerRebatesAccrued: UInt64
        
        let blob7: SerumSwap.Blob7
    }
    
    typealias GetOpenOrderResult = (existingOpenOrder: SerumSwap.PublicKey?, newOpenOrder: SerumSwap.SignersAndInstructions?)
}

