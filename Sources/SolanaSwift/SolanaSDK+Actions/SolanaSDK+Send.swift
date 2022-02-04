//
//  SolanaSDK+Send.swift
//  SolanaSwift
//
//  Created by Chung Tran on 25/01/2021.
//

import Foundation
import RxSwift

extension SolanaSDK {
    public typealias SPLTokenDestinationAddress = (destination: PublicKey, isUnregisteredAsocciatedToken: Bool)
    
    /// Create prepared transaction for sending SOL
    /// - Parameters:
    ///   - destination: destination wallet address
    ///   - amount: amount in lamports
    ///   - feePayer: customm fee payer, can be omited if the authorized user is the payer
    /// - Returns: PreparedTransaction, can be send either directly or via custom fee relayer
    public func prepareSendingNativeSOL(
        to destination: String,
        amount: UInt64,
        feePayer: PublicKey? = nil,
        recentBlockhash: String? = nil,
        lamportsPerSignature: Lamports? = nil
    ) -> Single<PreparedTransaction> {
        guard let account = self.accountStorage.account else {
            return .error(Error.unauthorized)
        }
        let feePayer = feePayer ?? account.publicKey
        do {
            let fromPublicKey = account.publicKey
            
            if fromPublicKey.base58EncodedString == destination {
                throw Error.other("You can not send tokens to yourself")
            }
            
            // check
            return getAccountInfo(account: destination, decodedTo: EmptyInfo.self)
                .map {info -> Void in
                    guard info.owner == PublicKey.programId.base58EncodedString
                    else {throw Error.other("Invalid account info")}
                    return
                }
                .catch { error in
                    if error.isEqualTo(.couldNotRetrieveAccountInfo) {
                        // let request through
                        return .just(())
                    }
                    throw error
                }
                .flatMap { [weak self] in
                    guard let self = self else {return .error(Error.unknown)}
                    // form instruction
                    let instruction = SystemProgram.transferInstruction(
                        from: fromPublicKey,
                        to: try PublicKey(string: destination),
                        lamports: amount
                    )
                    
                    return self.prepareTransaction(
                        instructions: [instruction],
                        signers: [account],
                        feePayer: feePayer,
                        accountsCreationFee: 0,
                        recentBlockhash: recentBlockhash,
                        lamportsPerSignature: lamportsPerSignature
                    )
                }
                
        } catch {
            return .error(error)
        }
    }
    
    /// Send SOL to another account
    /// - Parameters:
    ///   - destination: destination address
    ///   - amount: amount to send
    ///   - feePayer: customm fee payer, can be omited if the authorized user is the payer
    /// - Returns: transaction id
    public func sendNativeSOL(
        to destination: String,
        amount: UInt64,
        feePayer: PublicKey? = nil,
        isSimulation: Bool = false
    ) -> Single<TransactionID> {
        prepareSendingNativeSOL(
            to: destination,
            amount: amount,
            feePayer: feePayer
        )
            .flatMap { [weak self] preparedTransaction in
                guard let self = self else {return .error(Error.unknown)}
                return self.serializeAndSend(preparedTransaction: preparedTransaction, isSimulation: isSimulation)
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
    
    /// Create prepared transaction for sending SPL token
    public func prepareSendingSPLTokens(
        mintAddress: String,
        decimals: Decimals,
        from fromPublicKey: String,
        to destinationAddress: String,
        amount: UInt64,
        feePayer: PublicKey? = nil,
        transferChecked: Bool = false,
        recentBlockhash: String? = nil,
        lamportsPerSignature: Lamports? = nil,
        minRentExemption: Lamports? = nil
    ) -> Single<(preparedTransaction: PreparedTransaction, realDestination: String)> {
        guard let account = self.accountStorage.account else {
            return .error(Error.unauthorized)
        }
        
        let feePayer = feePayer ?? account.publicKey
        
        let minRentExemptionRequest: Single<Lamports>
        if let minRentExemption = minRentExemption {
            minRentExemptionRequest = .just(minRentExemption)
        } else {
            minRentExemptionRequest = getMinimumBalanceForRentExemption(dataLength: AccountInfo.span)
        }
        
        // Request
        return Single.zip(
            findSPLTokenDestinationAddress(
                mintAddress: mintAddress,
                destinationAddress: destinationAddress
            ),
            minRentExemptionRequest
        )
            .flatMap { [weak self] splDestinationAddress, minRentExempt in
                guard let self = self else {return .error(Error.unknown)}
                
                // get address
                let toPublicKey = splDestinationAddress.destination
                
                // catch error
                if fromPublicKey == toPublicKey.base58EncodedString {
                    throw Error.other("You can not send tokens to yourself")
                }
                
                let fromPublicKey = try PublicKey(string: fromPublicKey)
                
                var instructions = [TransactionInstruction]()
                
                // create associated token address
                var accountsCreationFee: UInt64 = 0
                if splDestinationAddress.isUnregisteredAsocciatedToken {
                    let mint = try PublicKey(string: mintAddress)
                    let owner = try PublicKey(string: destinationAddress)
                    
                    let createATokenInstruction = AssociatedTokenProgram.createAssociatedTokenAccountInstruction(
                        mint: mint,
                        associatedAccount: toPublicKey,
                        owner: owner,
                        payer: feePayer
                    )
                    instructions.append(createATokenInstruction)
                    accountsCreationFee += minRentExempt
                }
                
                // send instruction
                let sendInstruction: TransactionInstruction
                
                // use transfer checked transaction for proxy, otherwise use normal transfer transaction
                if transferChecked {
                    // transfer checked transaction
                    sendInstruction = TokenProgram.transferCheckedInstruction(
                        programId: .tokenProgramId,
                        source: fromPublicKey,
                        mint: try PublicKey(string: mintAddress),
                        destination: splDestinationAddress.destination,
                        owner: account.publicKey,
                        multiSigners: [],
                        amount: amount,
                        decimals: decimals
                    )
                } else {
                    // transfer transaction
                    sendInstruction = TokenProgram.transferInstruction(
                        tokenProgramId: .tokenProgramId,
                        source: fromPublicKey,
                        destination: toPublicKey,
                        owner: account.publicKey,
                        amount: amount
                    )
                }
                
                instructions.append(sendInstruction)
                
                var realDestination = destinationAddress
                if !splDestinationAddress.isUnregisteredAsocciatedToken
                {
                    realDestination = splDestinationAddress.destination.base58EncodedString
                }
                
                // if not, serialize and send instructions normally
                return self.prepareTransaction(
                    instructions: instructions,
                    signers: [account],
                    feePayer: feePayer,
                    accountsCreationFee: accountsCreationFee,
                    recentBlockhash: recentBlockhash,
                    lamportsPerSignature: lamportsPerSignature
                )
                    .map {(preparedTransaction: $0, realDestination: realDestination)}
            }
    }
    
    /// Send SPLTokens to another account
    /// - Parameters:
    ///   - mintAddress: the mint address to define Token
    ///   - fromPublicKey: source wallet address
    ///   - destinationAddress: destination wallet address
    ///   - amount: amount to send
    ///   - isSimulation: define if this is a simulation or real transaction
    ///   - customProxy: (optional) forward sending to a fee-relayer proxy
    /// - Returns: transaction id
    public func sendSPLTokens(
        mintAddress: String,
        decimals: Decimals,
        from fromPublicKey: String,
        to destinationAddress: String,
        amount: UInt64,
        feePayer: PublicKey? = nil,
        transferChecked: Bool = false,
        isSimulation: Bool = false
    ) -> Single<TransactionID> {
        prepareSendingSPLTokens(
            mintAddress: mintAddress,
            decimals: decimals,
            from: fromPublicKey,
            to: destinationAddress,
            amount: amount,
            feePayer: feePayer,
            transferChecked: transferChecked
        )
            .map {$0.preparedTransaction}
            .flatMap { [weak self] preparedTransaction in
                guard let self = self else {return .error(Error.unknown)}
                return self.serializeAndSend(preparedTransaction: preparedTransaction, isSimulation: isSimulation)
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
    public func findSPLTokenDestinationAddress(
        mintAddress: String,
        destinationAddress: String
    ) -> Single<SPLTokenDestinationAddress> {
        getAccountInfo(
            account: destinationAddress,
            decodedTo: SolanaSDK.AccountInfo.self
        )
            .map {info -> String in
                let toTokenMint = info.data.mint.base58EncodedString
                
                // detect if destination address is already a SPLToken address
                if mintAddress == toTokenMint {
                    return destinationAddress
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
                    return address.base58EncodedString
                }
                
                // token is of another type
                throw Error.invalidRequest(reason: "Wallet address is not valid")
            }
            .catch { error in
                // let request through if result of getAccountInfo is null (it may be a new SOL address)
                if error.isEqualTo(.couldNotRetrieveAccountInfo) {
                    let owner = try PublicKey(string: destinationAddress)
                    let tokenMint = try PublicKey(string: mintAddress)
                    
                    // create associated token address
                    let address = try PublicKey.associatedTokenAddress(
                        walletAddress: owner,
                        tokenMintAddress: tokenMint
                    )
                    return .just(address.base58EncodedString)
                }
                
                // throw another error
                throw error
            }
            .flatMap {toPublicKey -> Single<SPLTokenDestinationAddress> in
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
                            var isUnregisteredAsocciatedToken = true
                            
                            // if associated token account has been registered
                            if info?.owner == PublicKey.tokenProgramId.base58EncodedString &&
                                info?.data != nil
                            {
                                isUnregisteredAsocciatedToken = false
                            }
                            
                            // if not, create one in next step
                            return .just((destination: toPublicKey, isUnregisteredAsocciatedToken: isUnregisteredAsocciatedToken))
                        }
                }
                return .just((destination: toPublicKey, isUnregisteredAsocciatedToken: false))
            }
    }
}
