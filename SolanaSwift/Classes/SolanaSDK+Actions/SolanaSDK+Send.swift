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
            .map { toPublicKey -> String in
                if fromPublicKey == toPublicKey {
                    throw Error.other("You can not send tokens to yourself")
                }
                return toPublicKey
            }
            .flatMap {toPublicKey -> Single<(associatedTokenAddress: PublicKey, registered: Bool)> in
                let toPublicKey = try PublicKey(string: toPublicKey)
                // if destination address is an SOL account address
                if destinationAddress != toPublicKey.base58EncodedString {
                    // check if associated address is already registered
                    return self.getAccountInfo(
                        account: toPublicKey.base58EncodedString,
                        decodedTo: AccountInfo.self
                    )
                        .map {$0 as BufferInfo<AccountInfo>?}
                        .catchAndReturn(nil)
                        .flatMap {info in
                            // if associated token account has been registered
                            var registered = false
                            if info?.owner == PublicKey.tokenProgramId.base58EncodedString &&
                                info?.data.value != nil
                            {
                                registered = true
                            }
                            
                            // if not, create one in next step
                            return .just((associatedTokenAddress: toPublicKey, registered: registered))
                        }
                }
                return .just((associatedTokenAddress: toPublicKey, registered: true))
            }
            .flatMap {result in
                // get address
                let toPublicKey = result.associatedTokenAddress
                
                // catch error
                if fromPublicKey == toPublicKey.base58EncodedString {
                    throw Error.other("You can not send tokens to yourself")
                }
                
                let fromPublicKey = try PublicKey(string: fromPublicKey)
                
                var instructions = [TransactionInstruction]()
                
                // create associated token address
                if !result.registered {
                    let mint = try PublicKey(string: mintAddress)
                    let owner = try PublicKey(string: destinationAddress)
                    
                    let createATokenInstruction = AssociatedTokenProgram.createAssociatedTokenAccountInstruction(
                        mint: mint,
                        associatedAccount: toPublicKey,
                        owner: owner,
                        payer: account.publicKey
                    )
                    instructions.append(createATokenInstruction)
                }
                
                // send instruction
                let sendInstruction = TokenProgram.transferInstruction(
                    tokenProgramId: .tokenProgramId,
                    source: fromPublicKey,
                    destination: toPublicKey,
                    owner: account.publicKey,
                    amount: amount
                )
                
                instructions.append(sendInstruction)
                
                return self.serializeAndSend(instructions: instructions, signers: [account], isSimulation: isSimulation)
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
    ) -> Single<String> {
        getAccountInfo(
            account: destinationAddress,
            decodedTo: SolanaSDK.AccountInfo.self
        )
            .flatMap {info in
                let toTokenMint = info.data.value?.mint.base58EncodedString
                
                // detect if destination address is already a SPLToken address
                if mintAddress == toTokenMint {
                    return .just(destinationAddress)
                }
                
                // detect if destination address is a SOL address
                if info.owner == PublicKey.programId.base58EncodedString {
                    let owner = try PublicKey(string: destinationAddress)
                    let tokenMint = try PublicKey(string: mintAddress)
                    
                    // create associated token address
                    let address = try PublicKey.associatedTokenAddress(
                        walletAddress: owner,
                        tokenMintAddress: tokenMint
                    )
                    return .just(address.base58EncodedString)
                }
                
                // token is of another type
                throw Error.invalidRequest(reason: "Wallet address is not valid")
            }
    }
}
