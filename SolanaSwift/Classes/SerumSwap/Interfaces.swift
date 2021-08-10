//
//  Interfaces.swift
//  SolanaSwift
//
//  Created by Chung Tran on 09/08/2021.
//

import Foundation
import RxSwift
import BufferLayoutSwift

protocol SerumSwapAPIClient: OpenOrdersAPIClient {
    func getMarketAddressIfNeeded(fromMint: SolanaSDK.PublicKey, toMint: SolanaSDK.PublicKey) -> Single<SolanaSDK.PublicKey>
    func getMarketAddress(fromMint: SolanaSDK.PublicKey, toMint: SolanaSDK.PublicKey) -> Single<SolanaSDK.PublicKey>
    func serializeAndSend(
        instructions: [SolanaSDK.TransactionInstruction],
        signers: [SolanaSDK.Account]
    ) -> Single<SolanaSDK.TransactionID>
    func prepareSourceAccountAndInstructions(
        source: SolanaSDK.PublicKey,
        amount: SolanaSDK.Lamports,
        feePayer: SolanaSDK.PublicKey
    ) -> Single<SolanaSDK.AccountInstructions>
}

protocol OpenOrdersAPIClient {
    func getMinimumBalanceForRentExemption(span: UInt64) -> Single<UInt64>
    func getProgramAccounts<T: DecodableBufferLayout>(publicKey: String, configs: SolanaSDK.RequestConfiguration?, decodedTo: T.Type) -> Single<SolanaSDK.ProgramAccounts<T>>
}

protocol SerumSwapAccountProvider {
    func getNativeWalletAddress() -> SolanaSDK.PublicKey
}
