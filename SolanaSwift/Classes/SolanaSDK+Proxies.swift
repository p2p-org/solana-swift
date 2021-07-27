//
//  SolanaSDK+Proxies.swift
//  SolanaSwift
//
//  Created by Chung Tran on 16/07/2021.
//

import Foundation
import RxSwift

/// Custom Proxy for handling the fee by another service
public protocol SolanaCustomFeeRelayerProxy {
    func getFeePayer() -> Single<String>
    
    func transferSOL(
        sender: String,
        recipient: String,
        amount: SolanaSDK.Lamports,
        signature: String,
        blockhash: String,
        isSimulation: Bool
    ) -> Single<SolanaSDK.TransactionID>
    
    func transferSPLToken(
        sender: String,
        recipient: String,
        mintAddress: String,
        authority: String,
        amount: SolanaSDK.Lamports,
        decimals: SolanaSDK.Decimals,
        signature: String,
        blockhash: String
    ) -> Single<SolanaSDK.TransactionID>
    
    func swapToken(
        sourceToken: String,
        destinationToken: String,
        sourceTokenMint: String,
        destinationTokenMint: String,
        userAuthority: String,
        pool: SolanaSDK.Pool,
        amount: SolanaSDK.Lamports,
        minAmountOut: SolanaSDK.Lamports,
        feeCompensationPool: SolanaSDK.Pool,
        feeAmount: SolanaSDK.Lamports,
        feeMinAmountOut: SolanaSDK.Lamports,
        feePayerWSOLAccountKeypair: String,
        signature: String,
        blockhash: String
    ) -> Single<SolanaSDK.TransactionID>
}

extension SolanaSDK {
    /// Get signature from formed instructions
    /// - Parameters:
    ///   - feePayer: the feepayer gotten from getFeePayerPubkey
    ///   - instructions: instructions to get signature from
    ///   - recentBlockhash: recentBlockhash retrieved from server
    /// - Throws: error if signature not found
    /// - Returns: signature
    func getSignatureForProxy(
        feePayer: String,
        instructions: [TransactionInstruction],
        recentBlockhash: String
    ) throws -> String {
        guard let signer = accountStorage.account
        else {throw Error.unauthorized}
        let feePayer = try PublicKey(string: feePayer)
        var transaction = Transaction(feePayer: feePayer, instructions: instructions, recentBlockhash: recentBlockhash)
        try transaction.sign(signers: [signer])
        
        guard let signature = transaction.findSignature(pubkey: signer.publicKey)?.signature
        else {
            throw Error.other("Signature not found")
        }
        return Base58.encode(signature.bytes)
    }
}
