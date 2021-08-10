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
    public typealias SystemProgram = SolanaSDK.SystemProgram
    public typealias TokenProgram = SolanaSDK.TokenProgram
    
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
        client.getMarketAddressIfNeeded(
            fromMint: fromMint,
            toMint: toMint
        )
        .flatMap {[weak self] marketAddress in
            guard let self = self else {throw SerumSwapError.unknown}
            return self.createAndInitAccount(marketAddress: marketAddress)
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
        .flatMap {[weak self] marketFrom, marketTo -> Single<([OpenOrders], [OpenOrders], PublicKey, PublicKey)> in
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
                ),
                .just(marketFrom),
                .just(marketTo)
            )
        }
        .flatMap { [weak self] ooAccsFrom, ooAccsTo, marketFrom, marketTo in
            guard let self = self else {throw SerumSwapError.unknown}
            
            if ooAccsFrom.first != nil && ooAccsTo.first != nil {
                throw SerumSwapError("Open orders already exist")
            }
            
            if ooAccsFrom.first == nil {
                return self.createAndInitAccount(marketAddress: marketFrom)
            }
            
            if ooAccsTo.first == nil {
                return self.createAndInitAccount(marketAddress: marketTo)
            }
            
            throw SerumSwapError.unknown
        }
    }
    
    private func createAndInitAccount(
        marketAddress: PublicKey
    ) -> Single<SignersAndInstructions> {
        // create new account
        let newAccount: Account
        do {
            newAccount = try Account(network: .mainnetBeta)
        } catch {
            return .error(error)
        }
        
        let ownerAddress = accountProvider.getNativeWalletAddress()
        
        // form instruction
        return OpenOrders.makeCreateAccountInstruction(
            client: client,
            marketAddress: marketAddress,
            ownerAddress: ownerAddress,
            newAccountAddress: newAccount.publicKey,
            programId: dexPID
        )
        .map {createAccountInstruction in
            var instructions = [createAccountInstruction]
            // TODO: initAccount instruction
//            instructions.append(
//                    this.program.instruction.initAccount({
//                        accounts: {
//                            openOrders: openOrders.publicKey,
//                            authority: this.program.provider.wallet.publicKey,
//                            market: marketAddress,
//                            dexProgram: DEX_PID,
//                            rent: SYSVAR_RENT_PUBKEY,
//                        },
//                    }),
//            )
            let signers = [newAccount]
            return .init(signers: signers, instructions: instructions)
        }
        
    }
}
