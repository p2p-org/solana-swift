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
        private let solanaAPIClient: FeeRelayerSolanaAPIClient
        
        // MARK: - Initializer
        public init(solanaAPIClient: FeeRelayerSolanaAPIClient)
        {
            self.solanaAPIClient = solanaAPIClient
        }
        
        // MARK: - Methods
        public func getFeePayerPubkey() -> Single<SolanaSDK.PublicKey>
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
        
        // MARK: - Helpers
        private func makeTransferSOLInstructionAndParams(
            source: String,
            destination: String,
            amount: SolanaSDK.Lamports
        ) throws -> InstructionsAndParams {
            InstructionsAndParams(
                instructions: [
                    SystemProgram.transferInstruction(
                        from: try PublicKey(string: source),
                        to: try PublicKey(string: destination),
                        lamports: amount
                    )
                ],
                transferParams: TransferSolParams(
                    sender: source,
                    recipient: destination,
                    amount: amount
                ),
                path: "/transfer_sol"
            )
        }
        
        private func makeTransferTokenInstructionAndParams(
            source: String,
            destination: String,
            amount: SolanaSDK.Lamports,
            token: Token,
            owner: String? = nil
        ) throws -> InstructionsAndParams {
            let owner = owner ?? solanaAPIClient.accountStorage.account?.publicKey.base58EncodedString
            guard let owner = owner else {
                throw Error.unauthorized
            }
            return InstructionsAndParams(
                instructions: [
                    TokenProgram.transferInstruction(
                        tokenProgramId: .tokenProgramId,
                        source: try PublicKey(string: source),
                        destination: try PublicKey(string: destination),
                        owner: try PublicKey(string: owner),
                        amount: amount
                    )
                ],
                transferParams: TransferSPLTokenParams(
                    sender: source,
                    recipient: destination,
                    mintAddress: token.address,
                    authority: owner,
                    amount: amount,
                    decimals: token.decimals
                ),
                path: "/transfer_spl_token"
            )
        }
    }
}

