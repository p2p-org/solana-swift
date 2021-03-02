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
            
            var transaction = Transaction()
            transaction.message.add(
                instruction: SystemProgram.transferInstruction(
                    from: fromPublicKey,
                    to: toPublicKey,
                    lamports: amount
                )
            )
            
            return serializeAndSend(transaction: transaction, signers: [account], isSimulation: isSimulation)
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
                
                let fromPublicKey = try PublicKey(string: fromPublicKey)
                let toPublicKey = try PublicKey(string: toPublicKey)
                
                var transaction = Transaction()
                transaction.message.add(
                    instruction: TokenProgram.transferInstruction(
                        tokenProgramId: .tokenProgramId,
                        source: fromPublicKey,
                        destination: toPublicKey,
                        owner: account.publicKey,
                        amount: amount
                    )
                )
                return self.serializeAndSend(transaction: transaction, signers: [account], isSimulation: isSimulation)
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
            .map {$0.data.value?.mint.base58EncodedString}
            .flatMap {toTokenMint -> Single<String?> in
                // detect if destination address is already a SPLToken address
                if mintAddress == toTokenMint {
                    return .just(destinationAddress)
                }
                
                // detect if destination address is a SOL address
                return self.findSPLTokenWithMintAddress(mintAddress, fromAccountWithAddress: destinationAddress)
            }
            .map {
                if $0 == nil {
                    throw Error.other("The address is not valid")
                }
                return $0!
            }
    }
    
    private func findSPLTokenWithMintAddress(
        _ mintAddress: String,
        fromAccountWithAddress account: String
    ) -> Single<String?> {
        getAllSPLTokens(account: account)
            .map {$0.first(where: {$0.mintAddress == mintAddress})}
            .map {$0?.pubkey}
    }
}
