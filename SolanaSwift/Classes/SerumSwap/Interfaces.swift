//
//  Interfaces.swift
//  SolanaSwift
//
//  Created by Chung Tran on 09/08/2021.
//

import Foundation
import RxSwift
import BufferLayoutSwift

protocol SerumSwapAPIClient {
    func getAccountInfo<T: DecodableBufferLayout>(
        account: String,
        decodedTo: T.Type
    ) -> Single<SolanaSDK.BufferInfo<T>>
    func getMinimumBalanceForRentExemption(
        span: UInt64
    ) -> Single<UInt64>
    func getProgramAccounts<T: DecodableBufferLayout>(
        publicKey: String,
        configs: SolanaSDK.RequestConfiguration?,
        decodedTo: T.Type
    ) -> Single<SolanaSDK.ProgramAccounts<T>>
    func getMarketAddressIfNeeded(
        fromMint: SolanaSDK.PublicKey,
        toMint: SolanaSDK.PublicKey
    ) -> Single<SolanaSDK.PublicKey>
    func getMarketAddress(
        fromMint: SolanaSDK.PublicKey,
        toMint: SolanaSDK.PublicKey
    ) -> Single<SolanaSDK.PublicKey>
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
}

protocol SerumSwapAccountProvider {
    func getNativeWalletAddress() -> SolanaSDK.PublicKey
}
