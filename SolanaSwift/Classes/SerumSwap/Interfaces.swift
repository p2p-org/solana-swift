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
    ) -> Single<SolanaSDK.BufferInfo<T>>
    func getMintData(
        mintAddress: String,
        programId: String
    ) -> Single<SolanaSDK.Mint>
    func getMinimumBalanceForRentExemption(
        span: UInt64
    ) -> Single<UInt64>
    func getProgramAccounts<T: DecodableBufferLayout>(
        publicKey: String,
        configs: SolanaSDK.RequestConfiguration?,
        decodedTo: T.Type
    ) -> Single<SolanaSDK.ProgramAccounts<T>>
    // Returns the `usdxMint` quoted market address *if* no open orders account already exists.
    func getMarketAddressIfNeeded(
        usdxMint: SolanaSDK.PublicKey,
        baseMint: SolanaSDK.PublicKey
    ) -> Single<SolanaSDK.PublicKey>
    func getMarketAddress(
        usdxMint: SolanaSDK.PublicKey,
        baseMint: SolanaSDK.PublicKey
    ) -> Single<SolanaSDK.PublicKey>
    func getMarketAddresses(
        usdxMint: SolanaSDK.PublicKey,
        baseMint: SolanaSDK.PublicKey
    ) -> Single<[SolanaSDK.PublicKey]>
    func usdcPathExists(
        fromMint: SolanaSDK.PublicKey,
        toMint: SolanaSDK.PublicKey
    ) -> Single<Bool>
    func prepareSourceAccountAndInstructions(
        myNativeWallet: SolanaSDK.PublicKey,
        source: SolanaSDK.PublicKey,
        sourceMint: SolanaSDK.PublicKey,
        amount: SolanaSDK.Lamports,
        feePayer: SolanaSDK.PublicKey
    ) -> Single<SolanaSDK.AccountInstructions>
    func prepareDestinationAccountAndInstructions(
        myAccount: SolanaSDK.PublicKey,
        destination: SolanaSDK.PublicKey?,
        destinationMint: SolanaSDK.PublicKey,
        feePayer: SolanaSDK.PublicKey
    ) -> Single<SolanaSDK.AccountInstructions>
    func serializeTransaction(
        instructions: [SolanaSDK.TransactionInstruction],
        recentBlockhash: String?,
        signers: [SolanaSDK.Account],
        feePayer: SolanaSDK.PublicKey?
    ) -> Single<String>
    func simulateTransaction(
        transaction: String
    ) -> Single<SolanaSDK.TransactionStatus>
}

extension SerumSwapAPIClient {
    func getDecimals(mintAddress: SolanaSDK.PublicKey) -> Single<SolanaSDK.Decimals> {
        getMintData(
            mintAddress: mintAddress.base58EncodedString,
            programId: SolanaSDK.PublicKey.tokenProgramId.base58EncodedString
        )
            .map {$0.decimals}
    }
}

public protocol SerumSwapAccountProvider {
    func getNativeWalletAddress() -> SolanaSDK.PublicKey?
}
