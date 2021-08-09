//
//  SerumSwap.swift
//  SolanaSwift
//
//  Created by Chung Tran on 09/08/2021.
//

import Foundation
import RxSwift

public typealias Account = SolanaSDK.Account
public typealias TransactionInstruction = SolanaSDK.TransactionInstruction
public typealias PublicKey = SolanaSDK.PublicKey
public typealias TransactionID = SolanaSDK.TransactionID
public typealias AccountInfo = SolanaSDK.AccountInfo
public typealias SystemProgram = SolanaSDK.SystemProgram

protocol SerumSwapAPIClient {
    func getMarketAddressIfNeeded(fromMint: SolanaSDK.PublicKey, toMint: SolanaSDK.PublicKey) -> Single<SolanaSDK.PublicKey>
    func getMarketAddress(fromMint: SolanaSDK.PublicKey, toMint: SolanaSDK.PublicKey) -> Single<SolanaSDK.PublicKey>
    func getMinimumBalanceForRentExemption(span: UInt64) -> Single<UInt64>
    func serializeAndSend(
        instructions: [SolanaSDK.TransactionInstruction],
        signers: [SolanaSDK.Account]
    ) -> Single<SolanaSDK.TransactionID>
}

protocol SerumSwapAccountProvider {
    func getNativeWalletAddress() -> SolanaSDK.PublicKey
}

public class SerumSwap {
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
    ) -> Single<TransactionID> {
        
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
        // Transitive swap across USD(x).
        else {
            // Builds the instructions for initializing open orders for a transitive swap.
            // Build transitive with usdcMint
            request = buildTransitive(
                usdxMint: usdcMint,
                fromMint: fromMint,
                toMint: toMint
            )
                .catch {[weak self] _ in
                    guard let self = self else {return .error(SolanaSDK.Error.unknown)}
                    // Retry with building transitive with usdtMint
                    return self.buildTransitive(
                        usdxMint: self.usdtMint,
                        fromMint: fromMint,
                        toMint: toMint
                    )
                }
        }
        
        return request
            .flatMap {[weak self] signersAndInstructions in
                guard let self = self else {return .error(SolanaSDK.Error.unknown)}
                return self.client.serializeAndSend(
                    instructions: signersAndInstructions.instructions,
                    signers: signersAndInstructions.signers
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
            
            // TODO:
//                tx.add(
//                    this.program.instruction.initAccount({
//                        accounts: {
//                            openOrders: openOrders.publicKey,
//                            authority: this.program.provider.wallet.publicKey,
//                            market: marketAddress,
//                            dexProgram: DEX_PID,
//                            rent: SYSVAR_RENT_PUBKEY,
//                        },
//                    }),
//                );
            
            return .init(signers: signers, instructions: instructions)
        }
    }
    
    private func buildTransitive(
        usdxMint: PublicKey,
        fromMint: PublicKey,
        toMint: PublicKey
    ) -> Single<SignersAndInstructions> {
        // Markets
        let marketFrom = client.getMarketAddress(fromMint: usdxMint, toMint: fromMint)
        let marketTo = client.getMarketAddress(fromMint: usdxMint, toMint: toMint)
        
        // Open orders accounts (already existing).
        return Single.zip(
            
        )
    }
}
