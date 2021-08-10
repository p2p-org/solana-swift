//
//  SerumSwap.swift
//  SolanaSwift
//
//  Created by Chung Tran on 09/08/2021.
//

import Foundation
import RxSwift

// MARK: - Constants
private var usdcMint: SolanaSDK.PublicKey { try! SolanaSDK.PublicKey(string: "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v") }
private var usdtMint: SolanaSDK.PublicKey { try! SolanaSDK.PublicKey(string: "Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB") }
private var dexPID: SolanaSDK.PublicKey { try! SolanaSDK.PublicKey(string: "9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin") }

public class SerumSwap {
    public typealias Account = SolanaSDK.Account
    public typealias TransactionInstruction = SolanaSDK.TransactionInstruction
    public typealias PublicKey = SolanaSDK.PublicKey
    public typealias TransactionID = SolanaSDK.TransactionID
    public typealias AccountInfo = SolanaSDK.AccountInfo
    
    // MARK: - Nested type
    struct SignersAndInstructions {
        let signers: [Account]
        let instructions: [TransactionInstruction]
    }
    
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
                guard let self = self else {return .error(SerumSwapError.unknown)}
                // Retry with building transitive with usdtMint
                return self.buildTransitive(
                    usdxMint: usdtMint,
                    fromMint: fromMint,
                    toMint: toMint
                )
            }
        }
        
        return request
            .flatMap {[weak self] signersAndInstructions in
                guard let self = self else {return .error(SerumSwapError.unknown)}
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
            guard let self = self else {throw SerumSwapError.unknown}
            
            let openOrders = try Account(network: .mainnetBeta)
            
            // signers
            var signers = [Account]()
            signers.append(openOrders)
            
            // instructions
            var instructions = [TransactionInstruction]()
            
//            instructions.append(
//                SystemProgram.createAccountInstruction(
//                    from: self.accountProvider.getNativeWalletAddress(),
//                    toNewPubkey: openOrders.publicKey,
//                    lamports: minimumBalanceForRentExemption,
//                    programPubkey: self.dexPID
//                )
//            )
            
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
        Single.zip(
            client.getMarketAddress(fromMint: usdxMint, toMint: fromMint),
            client.getMarketAddress(fromMint: usdxMint, toMint: toMint)
        )
        .flatMap {[weak self] marketFrom, marketTo -> Single<([OpenOrders], [OpenOrders])> in
            guard let self = self else {throw SerumSwapError.unknown}
            return Single.zip(
                OpenOrders.findForMarketAndOwner(
                    client: self.client,
                    marketAddress: marketFrom,
                    ownerAddress: self.accountProvider.getNativeWalletAddress(),
                    programId: dexPID
                ),
                OpenOrders.findForMarketAndOwner(
                    client: self.client,
                    marketAddress: marketTo,
                    ownerAddress: self.accountProvider.getNativeWalletAddress(),
                    programId: dexPID
                )
            )
        }
        .map { ooAccsFrom, ooAccsTo in
            if ooAccsFrom.first != nil && ooAccsTo.first != nil {
                throw SerumSwapError("Open orders already exist")
            }
            
            // No open orders account for the from market, so make it.
            var signers = [Account]()
            var instructions = [TransactionInstruction]()
            
            if ooAccsFrom.first == nil {
                
            }
            
            if ooAccsTo.first == nil {
                
            }
            return SignersAndInstructions(signers: signers, instructions: instructions)
        }
    }
}
