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
    
    /// Send SOL to another account
    /// - Parameters:
    ///   - toPublicKey: destination address
    ///   - amount: amount to send
    ///   - isSimulation: define if this is a simulation or real transaction
    ///   - customProxy: (optional) forward sending to a fee-relayer proxy
    /// - Returns: transaction id
    public func sendNativeSOL(
        to destination: String,
        amount: UInt64,
        isSimulation: Bool = false,
        customProxy: SolanaCustomFeeRelayerProxy? = nil
    ) -> Single<TransactionID> {
        guard let account = self.accountStorage.account else {
            return .error(Error.unauthorized)
        }
        
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
                .flatMap {
                    // form instruction
                    let instruction = SystemProgram.transferInstruction(
                        from: fromPublicKey,
                        to: try PublicKey(string: destination),
                        lamports: amount
                    )
                    
                    // if a proxy is existed, form signature, instruction and send them to this proxy
                    if let proxy = customProxy {
                        // form signature
                        return Single.zip(
                            proxy.getFeePayer(),
                            self.getRecentBlockhash()
                        )
                            .map {feePayer, recentBlockhash in
                                (try self.getSignatureForProxy(
                                    feePayer: feePayer,
                                    instructions: [instruction],
                                    recentBlockhash: recentBlockhash),
                                 recentBlockhash)
                            }
                            .flatMap {signature, recentBlockhash in
                                proxy.transferSOL(
                                    sender: account.publicKey.base58EncodedString,
                                    recipient: destination,
                                    amount: amount,
                                    signature: signature,
                                    blockhash: recentBlockhash,
                                    isSimulation: isSimulation
                                )
                            }
                    }
                    
                    // if not, serialize and send instructions normally
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
        isSimulation: Bool = false,
        customProxy: SolanaCustomFeeRelayerProxy? = nil
    ) -> Single<TransactionID> {
        guard let account = self.accountStorage.account else {
            return .error(Error.unauthorized)
        }
        
        // OPTIONAL: custom fee payer request (for custom proxy)
        let customFeePayerRequest: Single<PublicKey>
        if let proxy = customProxy {
            customFeePayerRequest = proxy.getFeePayer().map {try .init(string: $0)}
        } else {
            customFeePayerRequest = .just(account.publicKey)
        }
        
        // Request
        return Single.zip(
            findSPLTokenDestinationAddress(
                mintAddress: mintAddress,
                destinationAddress: destinationAddress
            ),
            customFeePayerRequest
        )
            .flatMap {splDestinationAddress, feePayer in
                // get address
                let toPublicKey = splDestinationAddress.destination
                
                // catch error
                if fromPublicKey == toPublicKey.base58EncodedString {
                    throw Error.other("You can not send tokens to yourself")
                }
                
                let fromPublicKey = try PublicKey(string: fromPublicKey)
                
                var instructions = [TransactionInstruction]()
                
                // create associated token address
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
                }
                
                // send instruction
                let sendInstruction: TransactionInstruction
                
                // use transfer checked transaction for proxy, otherwise use normal transfer transaction
                if customProxy != nil {
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
                
                // if a proxy is existed, form signature, instruction and send them to this proxy
                if let proxy = customProxy {
                    // form signature
                    return Single.zip(
                        proxy.getFeePayer(),
                        self.getRecentBlockhash()
                    )
                        .map {feePayer, recentBlockhash in
                            (try self.getSignatureForProxy(
                                feePayer: feePayer,
                                instructions: instructions,
                                recentBlockhash: recentBlockhash),
                             recentBlockhash)
                        }
                        .flatMap {signature, recentBlockhash in
                            // get real destination: if associated token has been registered, then send token to this address, if not, send token to SOL account address
                            var realDestination = destinationAddress
                            if !splDestinationAddress.isUnregisteredAsocciatedToken
                            {
                                realDestination = splDestinationAddress.destination.base58EncodedString
                            }
                            
                            return proxy.transferSPLToken(
                                sender: fromPublicKey.base58EncodedString,
                                recipient: realDestination,
                                mintAddress: mintAddress,
                                authority: account.publicKey.base58EncodedString,
                                amount: amount,
                                decimals: decimals,
                                signature: signature,
                                blockhash: recentBlockhash
                            )
                        }
                }
                
                // if not, serialize and send instructions normally
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
