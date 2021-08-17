//
//  Interfaces.swift
//  SolanaSwift
//
//  Created by Chung Tran on 09/08/2021.
//

import Foundation
import RxSwift
import BufferLayoutSwift

public protocol SerumSwapAPIClient {
    func getAccountInfo<T: DecodableBufferLayout>(
        account: String,
        decodedTo: T.Type
    ) -> Single<SerumSwap.BufferInfo<T>>
    func getMintData(
        mintAddress: String,
        programId: String
    ) -> Single<SerumSwap.Mint>
    func getMinimumBalanceForRentExemption(
        span: UInt64
    ) -> Single<UInt64>
    func getProgramAccounts<T: DecodableBufferLayout>(
        publicKey: String,
        configs: SerumSwap.RequestConfiguration?,
        decodedTo: T.Type
    ) -> Single<SerumSwap.ProgramAccounts<T>>
    // Returns the `usdxMint` quoted market address *if* no open orders account already exists.
    func getMarketAddressIfNeeded(
        usdxMint: SerumSwap.PublicKey,
        baseMint: SerumSwap.PublicKey
    ) -> Single<SerumSwap.PublicKey>
    func getMarketAddress(
        usdxMint: SerumSwap.PublicKey,
        baseMint: SerumSwap.PublicKey
    ) -> Single<SerumSwap.PublicKey>
    func getMarketAddresses(
        usdxMint: SerumSwap.PublicKey,
        baseMint: SerumSwap.PublicKey
    ) -> Single<[SerumSwap.PublicKey]>
    func usdcPathExists(
        fromMint: SerumSwap.PublicKey,
        toMint: SerumSwap.PublicKey
    ) -> Single<Bool>
    func prepareValidAccountAndInstructions(
        myAccount: SerumSwap.PublicKey,
        address: SerumSwap.PublicKey?,
        mint: SerumSwap.PublicKey,
        feePayer: SerumSwap.PublicKey,
        closeAfterward: Bool
    ) -> Single<SerumSwap.AccountInstructions>
    func serializeTransaction(
        instructions: [SerumSwap.TransactionInstruction],
        recentBlockhash: String?,
        signers: [SerumSwap.Account],
        feePayer: SerumSwap.PublicKey?
    ) -> Single<String>
    func simulateTransaction(
        transaction: String
    ) -> Single<SerumSwap.TransactionStatus>
}

extension SerumSwapAPIClient {
    func getDecimals(mintAddress: SerumSwap.PublicKey) -> Single<SerumSwap.Decimals> {
        getMintData(
            mintAddress: mintAddress.base58EncodedString,
            programId: SerumSwap.PublicKey.tokenProgramId.base58EncodedString
        )
            .map {$0.decimals}
    }
}

public protocol SerumSwapAccountProvider {
    func getNativeWalletAddress() -> SerumSwap.PublicKey?
}

public protocol SerumSwapTokenListContainer {
    func getTokensList() -> Single<[SerumSwap.Token]>
}
