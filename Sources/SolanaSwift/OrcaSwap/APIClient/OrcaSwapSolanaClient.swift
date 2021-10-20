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
    
    func prepareSourceAccountAndInstructions(
        myNativeWallet: OrcaSwap.PublicKey,
        source: OrcaSwap.PublicKey,
        sourceMint: OrcaSwap.PublicKey,
        amount: OrcaSwap.Lamports,
        feePayer: OrcaSwap.PublicKey
    ) -> Single<OrcaSwap.AccountInstructions>
    
    func prepareDestinationAccountAndInstructions(
        myAccount: OrcaSwap.PublicKey,
        destination: OrcaSwap.PublicKey?,
        destinationMint: OrcaSwap.PublicKey,
        feePayer: OrcaSwap.PublicKey,
        closeAfterward: Bool
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
