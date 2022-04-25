//
//  SolanaSDK+AssociatedAccount.swift
//  SolanaSwift
//
//  Created by Chung Tran on 29/04/2021.
//

import Foundation
import RxSwift

extension SolanaSDK {
    public func getOrCreateAssociatedTokenAccount(
        owner: PublicKey,
        tokenMint: PublicKey,
        isSimulation: Bool = false
    ) -> Single<(transactionId: TransactionID?, associatedTokenAddress: PublicKey)> {
        guard let associatedAddress = try? PublicKey.associatedTokenAddress(
            walletAddress: owner,
            tokenMintAddress: tokenMint
        ) else {
            return .error(Error.other("Could not create associated token account"))
        }
        
        // check if token account exists
        return getAccountInfo(
            account: associatedAddress.base58EncodedString,
            decodedTo: AccountInfo.self
        )
            .map {Optional($0)}
            .catchAndReturn(nil)
            .flatMap { [weak self] info in
                guard let self = self else {throw Error.unknown}
                // if associated token account has been created
                if info?.owner == PublicKey.tokenProgramId.base58EncodedString &&
                    info?.data != nil
                {
                    return .just((transactionId: nil, associatedTokenAddress: associatedAddress))
                }
                
                // if not, create one
                return self.createAssociatedTokenAccount(
                    for: owner,
                    tokenMint: tokenMint,
                    isSimulation: isSimulation
                )
                    .map {(transactionId: $0, associatedTokenAddress: associatedAddress)}
            }
    }
    
    public func hasAssociatedTokenAccountBeenCreated(
        owner: PublicKey? = nil,
        tokenMint: PublicKey
    ) -> Single<Bool> {
        guard let owner = owner ?? accountStorage.account?.publicKey
        else {return .error(Error.unauthorized)}
        
        guard let associatedAddress = try? PublicKey.associatedTokenAddress(
            walletAddress: owner,
            tokenMintAddress: tokenMint
        ) else {
            return .error(Error.other("Could not create associated token account"))
        }
        
        return getAccountInfo(
            account: associatedAddress.base58EncodedString,
            decodedTo: AccountInfo.self
        )
            .map {info in
                (info.owner == PublicKey.tokenProgramId.base58EncodedString && info.data.owner == owner)
            }
    }
    
    public func createAssociatedTokenAccountInstruction(
        for owner: PublicKey,
        tokenMint: PublicKey,
        payer: PublicKey
    ) throws -> TransactionInstruction {
        do {
            let associatedAddress = try PublicKey.associatedTokenAddress(
                walletAddress: owner,
                tokenMintAddress: tokenMint
            )
    
            return AssociatedTokenProgram
                .createAssociatedTokenAccountInstruction(
                    mint: tokenMint,
                    associatedAccount: associatedAddress,
                    owner: owner,
                    payer: payer
                )
        }
    }
    
    public func createAssociatedTokenAccount(
        for owner: PublicKey,
        tokenMint: PublicKey,
        payer: Account? = nil,
        isSimulation: Bool = false
    ) -> Single<TransactionID> {
        // get account
        guard let payer = payer ?? accountStorage.account else {
            return .error(Error.unauthorized)
        }
        
        do {
            // create instruction
            let instruction = try createAssociatedTokenAccountInstruction(for: owner, tokenMint: tokenMint, payer: payer.publicKey)
            
            // send transaction
            return serializeAndSend(
                instructions: [instruction],
                signers: [payer],
                isSimulation: isSimulation
            )
        } catch {
            return .error(error)
        }
    }
}
