//
//  SolanaSDK+Swap.swift
//  SolanaSwift
//
//  Created by Chung Tran on 21/01/2021.
//

import Foundation
import RxSwift

extension SolanaSDK {
    public struct SwapResponse {
        public let transactionId: String
        public let newWalletPubkey: String?
        
        public init(transactionId: String, newWalletPubkey: String?) {
            self.transactionId = transactionId
            self.newWalletPubkey = newWalletPubkey
        }
    }
    
    public struct AccountInstructions {
        public init(
            account: SolanaSDK.PublicKey,
            instructions: [SolanaSDK.TransactionInstruction] = [],
            cleanupInstructions: [SolanaSDK.TransactionInstruction] = [],
            signers: [SolanaSDK.Account] = [],
            newWalletPubkey: String? = nil,
            secretKey: Data? = nil
        ) {
            self.account = account
            self.instructions = instructions
            self.cleanupInstructions = cleanupInstructions
            self.signers = signers
            self.newWalletPubkey = newWalletPubkey
            self.secretKey = secretKey
        }
        
        public let account: PublicKey
        public var instructions: [TransactionInstruction]
        public var cleanupInstructions: [TransactionInstruction]
        public let signers: [Account]
        
        // additionally return new wallet address
        fileprivate private(set) var newWalletPubkey: String?
        
        // additionally return newAccount's secretkey
        fileprivate private(set) var secretKey: Data?
    }
    
    // MARK: - Account and instructions
    public func prepareSourceAccountAndInstructions(
        myNativeWallet: PublicKey,
        source: PublicKey,
        sourceMint: PublicKey,
        amount: Lamports,
        feePayer: PublicKey
    ) -> Single<AccountInstructions> {
        // if token is non-native
        if source != myNativeWallet {
            return .just(
                .init(account: source)
            )
        }
        
        // if token is native
        return self.prepareCreatingWSOLAccountAndCloseWhenDone(
            from: source,
            amount: amount,
            payer: feePayer
        )
    }
    
    public func prepareDestinationAccountAndInstructions(
        myAccount: PublicKey,
        destination: PublicKey?,
        destinationMint: PublicKey,
        feePayer: PublicKey,
        closeAfterward: Bool
    ) -> Single<AccountInstructions> {
        // if destination is a registered non-native token account
        if let destination = destination, destination != myAccount
        {
            return .just(
                .init(account: destination)
            )
        }
        
        // if destination is a native account or is nil
        return prepareForCreatingAssociatedTokenAccount(
            owner: myAccount,
            mint: destinationMint,
            feePayer: feePayer,
            closeAfterward: closeAfterward
        )
    }
    
    // MARK: - Helpers
    public func prepareCreatingWSOLAccountAndCloseWhenDone(
        from owner: PublicKey,
        amount: Lamports,
        payer: PublicKey
    ) -> Single<AccountInstructions> {
        getMinimumBalanceForRentExemption(
            dataLength: UInt64(AccountInfo.BUFFER_LENGTH)
        )
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .map { [weak self] minimumBalanceForRentExemption in
                guard let self = self else {throw Error.unknown}
                // create new account
                let newAccount = try Account(network: self.endpoint.network)
                
                return .init(
                    account: newAccount.publicKey,
                    instructions: [
                        SystemProgram.createAccountInstruction(
                            from: owner,
                            toNewPubkey: newAccount.publicKey,
                            lamports: amount + minimumBalanceForRentExemption
                        ),
                        TokenProgram.initializeAccountInstruction(
                            account: newAccount.publicKey,
                            mint: .wrappedSOLMint,
                            owner: payer
                        )
                    ],
                    cleanupInstructions: [
                        TokenProgram.closeAccountInstruction(
                            account: newAccount.publicKey,
                            destination: payer,
                            owner: payer
                        )
                    ],
                    signers: [
                        newAccount
                    ],
                    secretKey: newAccount.secretKey
                )
            }
    }
    
    public func prepareForCreatingAssociatedTokenAccount(
        owner: PublicKey,
        mint: PublicKey,
        feePayer: PublicKey,
        closeAfterward: Bool
    ) -> Single<AccountInstructions> {
        do {
            let associatedAddress = try PublicKey.associatedTokenAddress(
                walletAddress: owner,
                tokenMintAddress: mint
            )
            
            return getAccountInfo(
                account: associatedAddress.base58EncodedString,
                decodedTo: AccountInfo.self
            )
                .observe(on: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
                // check if associated address is registered
                .map { info -> Bool in
                    if info.owner == PublicKey.tokenProgramId.base58EncodedString,
                       info.data.owner == owner
                    {
                        return true
                    }
                    throw Error.other("Associated token account is belong to another user")
                }
                .catch { error in
                    // associated address is not available
                    if error.isEqualTo(.couldNotRetrieveAccountInfo) {
                        return .just(false)
                    }
                    throw error
                }
                .map {isRegistered -> AccountInstructions in
                    // cleanup intructions
                    var cleanupInstructions = [TransactionInstruction]()
                    if closeAfterward {
                        cleanupInstructions = [
                            TokenProgram.closeAccountInstruction(
                                account: associatedAddress,
                                destination: owner,
                                owner: owner
                            )
                        ]
                    }
                    
                    // if associated address is registered, there is no need to creating it again
                    if isRegistered {
                        return .init(
                            account: associatedAddress,
                            cleanupInstructions: []
                        )
                    }
                    
                    // create associated address
                    return .init(
                        account: associatedAddress,
                        instructions: [
                            AssociatedTokenProgram
                                .createAssociatedTokenAccountInstruction(
                                    mint: mint,
                                    associatedAccount: associatedAddress,
                                    owner: owner,
                                    payer: feePayer
                                )
                        ],
                        cleanupInstructions: cleanupInstructions,
                        newWalletPubkey: associatedAddress.base58EncodedString
                    )
                }
        } catch {
            return .error(error)
        }
    }
}
