//
//  SerumSwap.swift
//  SolanaSwift
//
//  Created by Chung Tran on 09/08/2021.
//

import Foundation
import RxSwift

public protocol AccountType {
    init() throws
}

public protocol TransactionInstruction {
    
}

public protocol SystemProgram {
    
}

public protocol PublicKeyType: Equatable {
    static var usdcMint: Self {get}
    static var usdtMint: Self {get}
    static var dexPID: Self {get}
}

public protocol AccountInfoType {
    static var span: UInt64 {get}
}

public typealias TransactionID = String

protocol SerumSwapAPIClient {
    func getMarketAddressIfNeeded<PublicKey: PublicKeyType>(fromMint: PublicKey, toMint: PublicKey) -> Single<PublicKey>
    func getMarketAddress<PublicKey: PublicKeyType>(fromMint: PublicKey, toMint: PublicKey) -> Single<PublicKey>
    func getMinimumBalanceForRentExemption(span: UInt64) -> Single<UInt64>
    func serializeAndSend<Account: AccountType>(
        instructions: [TransactionInstruction],
        signers: [Account]
    ) -> Single<TransactionID>
}

protocol SerumSwapAccountProvider {
    func getNativeWalletAddress() -> SolanaSDK.PublicKey
}

public class SerumSwap<
    Account: AccountType,
    PublicKey: PublicKeyType,
    AccountInfo: AccountInfoType
> {
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
        if fromMint == PublicKey.usdcMint || fromMint == PublicKey.usdtMint {
            request = createAndInitAccountForDirectSwapOnUSDX(
                fromMint: fromMint,
                toMint: toMint
            )
        }
        else if toMint == PublicKey.usdcMint || toMint == PublicKey.usdtMint {
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
                usdxMint: PublicKey.usdcMint,
                fromMint: fromMint,
                toMint: toMint
            )
                .catch {[weak self] _ in
                    guard let self = self else {return .error(SolanaSDK.Error.unknown)}
                    // Retry with building transitive with usdtMint
                    return self.buildTransitive(
                        usdxMint: PublicKey.usdtMint,
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
            
            let openOrders = try Account()
            
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
        let marketFrom = client.getMarketAddress(fromMint: usdxMint, toMint: fromMint)
        let marketTo = client.getMarketAddress(fromMint: usdxMint, toMint: toMint)
        
        // Open orders accounts (already existing).
        fatalError()
    }
}
