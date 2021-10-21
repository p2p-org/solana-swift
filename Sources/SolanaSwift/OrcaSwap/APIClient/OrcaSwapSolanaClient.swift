//
//  File.swift
//  
//
//  Created by Chung Tran on 13/10/2021.
//

import Foundation
import RxSwift

public protocol OrcaSwapSolanaClient {
    func getTokenAccountBalance(pubkey: String, commitment: SolanaSDK.Commitment?) -> Single<SolanaSDK.TokenAccountBalance>
    
    func getMinimumBalanceForRentExemption(
        span: UInt64
    ) -> Single<UInt64>
    
    func prepareCreatingWSOLAccountAndCloseWhenDone(
        owner: OrcaSwap.PublicKey,
        amount: UInt64,
        accountRentExempt: UInt64?
    ) -> Single<OrcaSwap.AccountInstructions>
    
    func prepareCreatingAssociatedTokenAccount(
        owner: OrcaSwap.PublicKey,
        tokenMint: OrcaSwap.PublicKey
    ) -> Single<OrcaSwap.AccountInstructions>
    
    var endpoint: OrcaSwap.APIEndPoint {get}
    
    func serializeAndSend(
        instructions: [OrcaSwap.TransactionInstruction],
        recentBlockhash: String?,
        signers: [OrcaSwap.Account],
        isSimulation: Bool
    ) -> Single<String>
}

public protocol OrcaSwapAccountProvider {
    func getAccount() -> OrcaSwap.Account?
    func getNativeWalletAddress() -> OrcaSwap.PublicKey?
}

public protocol OrcaSwapSignatureConfirmationHandler {
    func waitForConfirmation(signature: String) -> Completable
}
