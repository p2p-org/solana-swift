//
//  FeeRelayer.swift
//  SolanaSwift
//
//  Created by Chung Tran on 12/05/2021.
//

import Foundation
import RxSwift
import RxAlamofire

public protocol FeeRelayerSolanaAPIClient {
    var accountStorage: SolanaSDKAccountStorage {get}
    func getRecentBlockhash() -> Single<String>
    func findSPLTokenDestinationAddress(
        mintAddress: String,
        destinationAddress: String
    ) -> Single<SolanaSDK.SPLTokenDestinationAddress>
}
extension SolanaSDK: FeeRelayerSolanaAPIClient {
    public func getRecentBlockhash() -> Single<String> {
        getRecentBlockhash(commitment: nil)
    }
}

extension SolanaSDK {
    public struct FeeRelayer {
        // MARK: - Constants
        private let feeRelayerUrl = "https://fee-relayer.solana.p2p.org"
        private let transferSOLPath     = "/transfer_sol"
        private let transferTokenPath   = "/transfer_spl_token"
        private let solanaAPIClient: FeeRelayerSolanaAPIClient
        
        // MARK: - Initializer
        public init(solanaAPIClient: FeeRelayerSolanaAPIClient)
        {
            self.solanaAPIClient = solanaAPIClient
        }
        
        // MARK: - Methods
        /// Get fee payer for free transaction
        /// - Returns: Account's public key that is responsible for paying fee
        public func getFeePayerPubkey() -> Single<PublicKey>
        {
            RxAlamofire.request(.get, "\(feeRelayerUrl)/fee_payer/pubkey")
                .validate(statusCode: 200..<300)
                .responseString()
                .map {try SolanaSDK.PublicKey(string: $0.1)}
                .take(1)
                .asSingle()
                .do(
                    onSuccess: {
                        Logger.log(message: $0.base58EncodedString, event: .response, apiMethod: "fee_payer/pubkey")
                    },
                    onError: {
                        Logger.log(message: $0.localizedDescription, event: .error, apiMethod: "fee_payer/pubkey")
                    })
        }
        
        /// Transfer SOL without fee
        /// - Parameters:
        ///   - destination: SOL destination wallet
        ///   - amount: Amount in lamports
        /// - Returns: Transaction id
        public func transferSOL(
            to destination: String,
            amount: SolanaSDK.Lamports
        ) -> Single<TransactionID>
        {
            guard let account = solanaAPIClient.accountStorage.account
            else {return .error(Error.unauthorized)}
            
            return Single.zip([
                getFeePayerPubkey().map {$0.base58EncodedString},
                solanaAPIClient.getRecentBlockhash()
            ])
                .map { result -> (signature: String, blockhash: String) in
                    let feePayer = result[0]
                    let recentBlockhash = result[1]
                    let instruction = SystemProgram.transferInstruction(
                        from: try PublicKey(string: account.publicKey.base58EncodedString),
                        to: try PublicKey(string: destination),
                        lamports: amount
                    )
                    let signature = try self.getSignature(
                        feePayer: feePayer,
                        instructions: [instruction],
                        recentBlockhash: recentBlockhash
                    )
                    return (signature: Base58.encode(signature.bytes), blockhash: recentBlockhash)
                }
                .flatMap {result in
                    self.sendTransaction(
                        path: transferSOLPath,
                        params: TransferSolParams(
                            sender: account.publicKey.base58EncodedString,
                            recipient: destination,
                            amount: amount,
                            signature: result.signature,
                            blockhash: result.blockhash
                        )
                    )
                }
        }
        
        /// Send SPL Token without fee
        /// - Parameters:
        ///   - source: source token wallet
        ///   - destination: destination token wallet
        ///   - token: token info
        ///   - amount: amount in lamport
        /// - Returns: Transaction id
        public func transferSPLToken(
            mintAddress: String,
            from source: String,
            to destination: String,
            amount: Lamports,
            decimals: Decimals
        ) -> Single<TransactionID> {
            guard let account = solanaAPIClient.accountStorage.account
            else {return .error(Error.unauthorized)}
            
            return Single.zip([
                getFeePayerPubkey().map {$0.base58EncodedString as Any},
                solanaAPIClient.getRecentBlockhash().map {$0 as Any},
                solanaAPIClient.findSPLTokenDestinationAddress(mintAddress: mintAddress, destinationAddress: destination).map {$0 as Any}
            ])
                .map { result -> (signature: String, blockhash: String, realDestination: String) in
                    // get result of asynchronous requests
                    let feePayer = result[0] as! String
                    let recentBlockhash = result[1] as! String
                    let splTokenDestinationAddress = result[2] as! SPLTokenDestinationAddress
                    
                    // form instructions
                    var instructions = [TransactionInstruction]()
                    
                    // form register instruction for registering associated token if it has not been registered yet
                    if splTokenDestinationAddress.isUnregisteredAsocciatedToken
                    {
                        let createATokenInstruction = AssociatedTokenProgram.createAssociatedTokenAccountInstruction(
                            mint: try PublicKey(string: mintAddress),
                            associatedAccount: splTokenDestinationAddress.destination,
                            owner: try PublicKey(string: destination),
                            payer: try PublicKey(string: feePayer)
                        )
                        instructions.append(createATokenInstruction)
                    }
                    
                    // form transfer instruction
                    let transferInstruction = TokenProgram.transferCheckedInstruction(
                        programId: .tokenProgramId,
                        source: try PublicKey(string: source),
                        mint: try PublicKey(string: mintAddress),
                        destination: splTokenDestinationAddress.destination,
                        owner: account.publicKey,
                        multiSigners: [],
                        amount: amount,
                        decimals: decimals
                    )
                    instructions.append(transferInstruction)
                    
                    // get signature from instructions
                    let signature = try self.getSignature(
                        feePayer: feePayer,
                        instructions: instructions,
                        recentBlockhash: recentBlockhash
                    )
                    
                    // get real destination: if associated token has been registered, then send token to this address, if not, send token to SOL account address
                    var realDestination = destination
                    if !splTokenDestinationAddress.isUnregisteredAsocciatedToken
                    {
                        realDestination = splTokenDestinationAddress.destination.base58EncodedString
                    }
                    
                    // send result to catcher
                    return (signature: Base58.encode(signature.bytes), blockhash: recentBlockhash, realDestination: realDestination)
                }
                .flatMap {result in
                    self.sendTransaction(
                        path: transferTokenPath,
                        params: TransferSPLTokenParams(
                            sender: source,
                            recipient: result.realDestination,
                            mintAddress: mintAddress,
                            authority: account.publicKey.base58EncodedString,
                            amount: amount,
                            decimals: decimals,
                            signature: result.signature,
                            blockhash: result.blockhash
                        )
                    )
                }
        }
        
        // MARK: - Helpers
        /// Get signature from formed instructions
        /// - Parameters:
        ///   - feePayer: the feepayer gotten from getFeePayerPubkey
        ///   - instructions: instructions to get signature from
        ///   - recentBlockhash: recentBlockhash retrieved from server
        /// - Throws: error if signature not found
        /// - Returns: signature
        private func getSignature(
            feePayer: String,
            instructions: [TransactionInstruction],
            recentBlockhash: String
        ) throws -> Data {
            guard let signer = solanaAPIClient.accountStorage.account
            else {throw Error.unauthorized}
            let feePayer = try PublicKey(string: feePayer)
            var transaction = Transaction(feePayer: feePayer, instructions: instructions, recentBlockhash: recentBlockhash)
            try transaction.sign(signers: [signer])
            
            guard let signature = transaction.findSignature(pubkey: signer.publicKey)?.signature
            else {
                throw Error.other("Signature not found")
            }
            return signature
        }
        
        /// Send transaction to fee relayer
        /// - Parameters:
        ///   - path: additional path for request
        ///   - params: request's parameters
        /// - Returns: transaction id
        private func sendTransaction(
            path: String,
            params: SolanaFeeRelayerTransferParams
        ) -> Single<SolanaSDK.TransactionID> {
            do {
                var urlRequest = try URLRequest(
                    url: "\(feeRelayerUrl)\(path)",
                    method: .post,
                    headers: [.contentType("application/json")]
                )
                urlRequest.httpBody = try JSONEncoder().encode(EncodableWrapper(wrapped: params))
                
                return RxAlamofire.request(urlRequest)
                    .validate(statusCode: 200..<300)
                    .responseString()
                    .map {$0.1}
                    .take(1)
                    .asSingle()
            } catch {
                return .error(error)
            }
        }
    }
}

