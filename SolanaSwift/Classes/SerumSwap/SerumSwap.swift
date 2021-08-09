//
//  SerumSwap.swift
//  SolanaSwift
//
//  Created by Chung Tran on 09/08/2021.
//

import Foundation
import RxSwift

protocol SerumSwapAPIClient {
    func getMarketAddressIfNeeded(fromMint: SolanaSDK.PublicKey, toMint: SolanaSDK.PublicKey) -> Single<SolanaSDK.PublicKey>
    func getMinimumBalanceForRentExemption(span: UInt64) -> Single<UInt64>
}

protocol SerumSwapAccountProvider {
    func getNativeWalletAddress() -> SolanaSDK.PublicKey
}

extension SolanaSDK {
    class SerumSwap {
        // MARK: - Nested type
        struct SignersAndInstructions {
            let signers: [Account]
            let instructions: [TransactionInstruction]
        }
        
        // MARK: - Constants
        let usdcMint = try! SolanaSDK.PublicKey(string: "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v")
        let usdtMint = try! SolanaSDK.PublicKey(string: "Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB")
        let dexPID = try! SolanaSDK.PublicKey(string: "9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin")
        
        // MARK: - Properties
        let client: SerumSwapAPIClient
        let accountProvider: SerumSwapAccountProvider
        
        // MARK: - Initializers
        init(client: SerumSwapAPIClient, accountProvider: SerumSwapAccountProvider) {
            self.client = client
            self.accountProvider = accountProvider
        }
        
        /**
         * Sends a transaction to initialize all accounts required for a swap between
         * the two mints. I.e., creates the DEX open orders accounts.
         *
         * @throws if all open orders accounts already exist.
         */
        public func initAccounts(
            fromMint: PublicKey,
            toMint: PublicKey
        ) -> Single<PublicKey> {
            
            let request: Single<SignersAndInstructions>
            
            // Direct swap on USD(x).
            if fromMint == usdcMint || fromMint == usdtMint {
                request = createAndInitAccountForDirectSwapOnUSDX(
                    fromMint: fromMint,
                    toMint: toMint
                )
            }
            else if toMint == usdcMint || toMint == usdtMint {
                request = createAndInitAccountForDirectSwapOnUSDX(
                    fromMint: toMint,
                    toMint: fromMint
                )
            }
            
        }
        
        // MARK: - Helpers
        private func createAndInitAccountForDirectSwapOnUSDX(
            fromMint: PublicKey,
            toMint: PublicKey
        ) -> Single<SignersAndInstructions>
        {
            Single.zip(
                client.getMarketAddressIfNeeded(
                    fromMint: fromMint,
                    toMint: toMint
                ),
                client.getMinimumBalanceForRentExemption(
                    span: AccountInfo.span
                )
            )
                .map {[weak self] marketAddress, minimumBalanceForRentExemption in
                    guard let self = self else {throw SolanaSDK.Error.unknown}
                    
                    let openOrders = try Account(network: .mainnetBeta)
                    
                    // signers
                    var signers = [Account]()
                    signers.append(openOrders)
                    
                    // instructions
                    var instructions = [TransactionInstruction]()
                    
                    instructions.append(
                        SystemProgram.createAccountInstruction(
                            from: self.accountProvider.getNativeWalletAddress(),
                            toNewPubkey: openOrders.publicKey,
                            lamports: minimumBalanceForRentExemption,
                            programPubkey: self.dexPID
                        )
                    )
                    
                    instructions.append(
                        TokenProgram.initializeAccountInstruction(programId: <#T##SolanaSDK.PublicKey#>, account: <#T##SolanaSDK.PublicKey#>, mint: <#T##SolanaSDK.PublicKey#>, owner: <#T##SolanaSDK.PublicKey#>)
                    )
                    
                    return .init(signers: signers, instructions: instructions)
                }
        }
    }
}
