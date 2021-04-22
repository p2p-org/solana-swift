//
//  SolanaSDK+Send.swift
//  SolanaSwift
//
//  Created by Chung Tran on 25/01/2021.
//

import Foundation
import RxSwift

extension SolanaSDK {
    /**
        send SOL to another account.
     
        - Parameter to: publicKey to send to
        - Parameter amount: amount to send
    */
    public func sendSOL(
        to toPublicKey: String,
        amount: UInt64,
        isSimulation: Bool = false
    ) -> Single<TransactionID> {
        guard let account = self.accountStorage.account else {
            return .error(Error.unauthorized)
        }
        
        do {
            let fromPublicKey = account.publicKey
            let toPublicKey = try PublicKey(string: toPublicKey)
            
            if fromPublicKey == toPublicKey {
                throw Error.other("You can not send tokens to yourself")
            }
            
            // check
            return getAccountInfo(account: toPublicKey.base58EncodedString, decodedTo: EmptyInfo.self)
                .map {info -> Void in
                    guard info.owner == PublicKey.programId.base58EncodedString
                    else {throw Error.other("Invalid account info")}
                    return
                }
                .flatMap {
                    let instruction = SystemProgram.transferInstruction(
                        from: fromPublicKey,
                        to: toPublicKey,
                        lamports: amount
                    )
                    
                    return self.serializeAndSend(
                        instructions: [instruction],
                        signers: [account],
                        isSimulation: isSimulation
                    )
                }
                .catch {error in
                    var error = error
                    if error.localizedDescription == "Invalid param: WrongSize"
                    {
                        error = Error.other("Wrong wallet address")
                    }
                    throw error
                }
        } catch {
            return .error(error)
        }
    }
    
    /**
        send SPLTokens to another account.
     
        - Parameter to: publicKey to send to, it may be splToken PublicKey or SOL address
        - Parameter amount: amount to send
    */
    public func sendSPLTokens(
        mintAddress: String,
        from fromPublicKey: String,
        to destinationAddress: String,
        amount: UInt64,
        isSimulation: Bool = false
    ) -> Single<TransactionID> {
        guard let account = self.accountStorage.account else {
            return .error(Error.unauthorized)
        }
        
        return findDestinationPublicKey(
            mintAddress: mintAddress,
            destinationAddress: destinationAddress
        )
            .flatMap {toPublicKey in
                if fromPublicKey == toPublicKey {
                    throw Error.other("You can not send tokens to yourself")
                }
                
                // If wallet with such token exists
                if let toPublicKey = toPublicKey {
                    let fromPublicKey = try PublicKey(string: fromPublicKey)
                    let toPublicKey = try PublicKey(string: toPublicKey)
                    
                    let instruction = TokenProgram.transferInstruction(
                        tokenProgramId: .tokenProgramId,
                        source: fromPublicKey,
                        destination: toPublicKey,
                        owner: account.publicKey,
                        amount: amount
                    )
                    
                    return self.serializeAndSend(instructions: [instruction], signers: [account], isSimulation: isSimulation)
                }
                
                // If the recipient does not have a wallet with such a wrapped token, first we create one at the sender's expense, and then we credit the tokens to the corresponding account.
                return self.createAndTransferToAccount(
                    destinationAddress,
                    mintAddress: mintAddress,
                    sourceAddress: fromPublicKey,
                    amount: amount,
                    isSimulation: isSimulation
                )
            }
            .catch {error in
                var error = error
                if error.localizedDescription == "Invalid param: WrongSize"
                {
                    error = Error.other("Wrong wallet address")
                }
                throw error
            }
    }
    
    // MARK: - Helpers
    private func findDestinationPublicKey(
        mintAddress: String,
        destinationAddress: String
    ) -> Single<String?> {
        getAccountInfo(
            account: destinationAddress,
            decodedTo: SolanaSDK.AccountInfo.self
        )
            .flatMap {info -> Single<String?> in
                let toTokenMint = info.data.value?.mint.base58EncodedString
                
                // detect if destination address is already a SPLToken address
                if mintAddress == toTokenMint {
                    return .just(destinationAddress)
                }
                
                // detect if destination address is a SOL address
                if info.owner == PublicKey.programId.base58EncodedString {
                    return self.findSPLTokenWithMintAddress(mintAddress, fromAccountWithAddress: destinationAddress)
                }
                
                // token is of another type
                throw Error.invalidRequest(reason: "Wallet address is not valid")
            }
    }
    
    private func findSPLTokenWithMintAddress(
        _ mintAddress: String,
        fromAccountWithAddress account: String
    ) -> Single<String?> {
        getTokenWallets(account: account)
            .map {$0.first(where: {$0.token.address == mintAddress})}
            .map {$0?.pubkey}
    }
    
    private func createAndTransferToAccount(
        _ destinationAccount: String,
        mintAddress: String,
        sourceAddress: String,
        amount: UInt64,
        isSimulation: Bool
    ) -> Single<TransactionID> {
        guard let payer = self.accountStorage.account else {
            return .error(Error.unauthorized)
        }
        
        var newAccount: Account!
        
        return Single.zip(
            getRecentBlockhash(),
            getCreatingTokenAccountFee()
        )
            .flatMap { (recentBlockhash, minBalance) in
                
                let mintAddress = try PublicKey(string: mintAddress)
                
                let destinationAccount = try PublicKey(string: destinationAccount)
                
                let sourceAddress = try PublicKey(string: sourceAddress)
                
                // create new account for token
                newAccount = try Account(network: self.network)
                
                // instructions
                let assertOwnerInstruction = SystemProgram.assertOwnerInstruction(destinationAccount: destinationAccount)
                
                let createAccountInstruction = SystemProgram.createAccountInstruction(
                    from: payer.publicKey,
                    toNewPubkey: newAccount.publicKey,
                    lamports: minBalance
                )
                
                let initializeAccountInstruction = TokenProgram.initializeAccountInstruction(
                    account: newAccount.publicKey,
                    mint: mintAddress,
                    owner: destinationAccount // create for destinationAccount, not for yourself
                )
                
                let transferInstruction = TokenProgram.transferInstruction(
                    tokenProgramId: .tokenProgramId,
                    source: sourceAddress,
                    destination: newAccount.publicKey,
                    owner: payer.publicKey,
                    amount: amount
                )
                
                // forming transaction
                let instructions = [
                    assertOwnerInstruction,
                    createAccountInstruction,
                    initializeAccountInstruction,
                    transferInstruction
                ]
                
                return self.serializeAndSend(
                    instructions: instructions,
                    recentBlockhash: recentBlockhash,
                    signers: [payer, newAccount],
                    isSimulation: isSimulation
                )
            }
    }
}
