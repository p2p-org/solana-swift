//
// Created by Giang Long Tran on 29.10.21.
//

import Foundation
import RxSwift

public extension SolanaSDK {
    
    struct OrcaSwapParser {
        private let solanaSDK: SolanaSDK
        
        private let supportedProgramId = [
            PublicKey.orcaSwapId(version: 1).base58EncodedString,
            PublicKey.orcaSwapId(version: 2).base58EncodedString, /*swap ocra*/
            "9qvG1zUp8xF1Bi4m6UdRNby1BAAuaDrUxSpv4CmRRMjL", /*main deprecated*/
            "SwaPpA9LAaLfeLi3a68M4DjnLqgtticKg6CnyNwgAC8" /*main deprecated*/
        ]
        
        init(solanaSDK: SolanaSDK) {
            self.solanaSDK = solanaSDK
        }
        
        /**
         Check instruction can be parsed
         */
        func can(instructions: [ParsedInstruction]) -> Bool {
            instructions.contains(where: { supportedProgramId.contains($0.programId) })
        }
        
        /**
        Check liquidity to pool
        - Parameter instructions: inner instructions
        */
        private func isLiquidityToPool(innerInstructions: [InnerInstruction]?) -> Bool {
            let instructions = innerInstructions?.first?.instructions
            switch (instructions?.count) {
            case 3:
                return instructions![0].parsed?.type == "transfer" &&
                    instructions![1].parsed?.type == "transfer" &&
                    instructions![2].parsed?.type == "mintTo"
            default:
                return false
            }
        }
        
        /**
        Check liquidity to pool
        - Parameter instructions: inner instructions
        */
        private func isBurn(innerInstructions: [InnerInstruction]?) -> Bool {
            let instructions = innerInstructions?.first?.instructions
            switch (instructions?.count) {
            case 3:
                return instructions?.count == 3 &&
                    instructions![0].parsed?.type == "burn" &&
                    instructions![1].parsed?.type == "transfer" &&
                    instructions![2].parsed?.type == "transfer"
            default:
                return false
            }
        }
        
        func parse(transactionInfo: TransactionInfo, myAccountSymbol: String?) -> Single<SwapTransaction?> {
            let innerInstructions = transactionInfo.meta?.innerInstructions
            
            switch (true) {
            case isLiquidityToPool(innerInstructions: innerInstructions): return .just(nil)
            case isBurn(innerInstructions: innerInstructions): return .just(nil)
            default:
                return _parse(
                    transactionInfo: transactionInfo,
                    myAccountSymbol: myAccountSymbol
                )
            }
        }
        
        private func _parse(transactionInfo: TransactionInfo, myAccountSymbol: String?) -> Single<SwapTransaction?> {
            let swapInstructions = transactionInfo.instructionsData().filter {
                supportedProgramId.contains($0.instruction.programId)
            }
            
            guard swapInstructions.count > 0 else {
                return .just(nil)
            }
            
            // Get inner instructions, that show transfer
            guard let source = swapInstructions.first?.innerInstruction?.instructions.first,
                  let destination = swapInstructions.last?.innerInstruction?.instructions.last else {
                // Failed case
                return .just(nil)
            }
            
            let sourceInfo = source.parsed?.info
            let destinationInfo = destination.parsed?.info
            
            return Single.zip(
                solanaSDK.getAccountInfo(account: sourceInfo?.source, retryWithAccount: sourceInfo?.destination),
                solanaSDK.getAccountInfo(account: destinationInfo?.destination, retryWithAccount: destinationInfo?.source)
            ).flatMap { accounts in
                Single.zip(
                    self.solanaSDK.getTokenWithMint(accounts.0?.mint.base58EncodedString),
                    self.solanaSDK.getTokenWithMint(accounts.1?.mint.base58EncodedString)
                ).map { tokens in
                    (
                        Wallet(
                            pubkey: try? PublicKey(string: sourceInfo?.source).base58EncodedString,
                            lamports: accounts.0?.lamports,
                            token: tokens.0
                        ),
                        Wallet(
                            pubkey: try? PublicKey(string: destinationInfo?.source).base58EncodedString,
                            lamports: accounts.1?.lamports,
                            token: tokens.1
                        )
                    )
                }
            }.flatMap { wallets -> Single<SwapTransaction?> in
                let source = wallets.0
                let destination = wallets.1
                
                let sourceAmountLamports = Lamports(sourceInfo?.amount ?? "0")
                let destinationAmountLamports = Lamports(destinationInfo?.amount ?? "0")
                
                // get decimals
                return .just(
                    SwapTransaction(
                        source: source,
                        sourceAmount: sourceAmountLamports?.convertToBalance(decimals: source.token.decimals),
                        destination: destination,
                        destinationAmount: destinationAmountLamports?.convertToBalance(decimals: destination.token.decimals),
                        myAccountSymbol: myAccountSymbol
                    )
                )
            }.catchAndReturn(nil)
            
            // get instruction
//            guard index < instructions.count else {
//                return .just(nil)
//            }
//            let instruction = instructions[index]
            
            // group request
//            var request: Single<(source: Wallet?, destination: Wallet?)>
//            var sourceAmountLamports: Lamports?
//            var destinationAmountLamports: Lamports?
//
//            // check inner instructions
//            if let swapInnerInstruction = innerInstructions?.first(where: { $0.index == index }) {
//                // get instructions
//                let transfersInstructions = swapInnerInstruction.instructions.filter {
//                    $0.parsed?.type == "transfer"
//                }
//                guard transfersInstructions.count >= 2 else {
//                    return .just(nil)
//                }
//
//                let sourceInstruction = transfersInstructions[0]
//                let destinationInstruction = transfersInstructions[1]
//
//                let sourceInfo = sourceInstruction.parsed?.info
//                let destinationInfo = destinationInstruction.parsed?.info
//
//                // get source
//                var accountInfoRequests = [Single<AccountInfo?>]()
//                var sourcePubkey: PublicKey?
//                if let sourceString = sourceInfo?.source {
//                    sourcePubkey = try? PublicKey(string: sourceString)
//                    accountInfoRequests.append(
//                        solanaSDK.getAccountInfo(account: sourceString, retryWithAccount: sourceInfo?.destination)
//                    )
//                }
//
//                var destinationPubkey: PublicKey?
//                if let destinationString = destinationInfo?.destination {
//                    destinationPubkey = try? PublicKey(string: destinationString)
//                    accountInfoRequests.append(
//                        solanaSDK.getAccountInfo(account: destinationString, retryWithAccount: destinationInfo?.source)
//                    )
//                }
//
//                request = Single.zip(accountInfoRequests)
//                    .flatMap { params -> Single<(source: Wallet?, destination: Wallet?)> in
//                        // get source, destination account info
//                        let sourceAccountInfo = params[0]
//                        let destinationAccountInfo = params[1]
//
//                        return Single.zip(
//                                getTokenWithMint(sourceAccountInfo?.mint.base58EncodedString),
//                                getTokenWithMint(destinationAccountInfo?.mint.base58EncodedString)
//                            )
//                            .map { sourceToken, destinationToken in
//                                let source = Wallet(
//                                    pubkey: sourcePubkey?.base58EncodedString,
//                                    lamports: sourceAccountInfo?.lamports,
//                                    token: sourceToken
//                                )
//                                let destination = Wallet(
//                                    pubkey: destinationPubkey?.base58EncodedString,
//                                    lamports: destinationAccountInfo?.lamports,
//                                    token: destinationToken
//                                )
//                                return (source: source, destination: destination)
//                            }
//                    }
//
//                sourceAmountLamports = Lamports(sourceInfo?.amount ?? "0")
//                destinationAmountLamports = Lamports(destinationInfo?.amount ?? "0")
//            }
//
//            // check instructions for failed transaction
//            else if let approveInstruction = instructions
//                .first(where: { $0.parsed?.type == "approve" }),
//                    let sourceAmountString = approveInstruction.parsed?.info.amount,
//                    let sourceMint = postTokenBalances?.first?.mint,
//                    let destinationMint = postTokenBalances?.last?.mint {
//                // form request
//                request = Single.zip(
//                        getTokenWithMint(sourceMint),
//                        getTokenWithMint(destinationMint)
//                    )
//                    .map { sourceToken, destinationToken in
//                        let source = Wallet(
//                            pubkey: approveInstruction.parsed?.info.source,
//                            lamports: Lamports(postTokenBalances?.first?.uiTokenAmount.amount ?? "0"),
//                            token: sourceToken
//                        )
//                        var destinationPubkey: String?
//
//                        if destinationToken.symbol == "SOL" {
//                            destinationPubkey = approveInstruction.parsed?.info.owner
//                        }
//                        let destination = Wallet(
//                            pubkey: destinationPubkey,
//                            lamports: Lamports(postTokenBalances?.last?.uiTokenAmount.amount ?? "0"),
//                            token: destinationToken
//                        )
//                        return (source: source, destination: destination)
//                    }
//
//                sourceAmountLamports = Lamports(sourceAmountString)
//                destinationAmountLamports = nil // because of the error
//            }
//
//            // unknown
//            else {
//                return .just(nil)
//            }
//
//            // get token account info
//            return request
//                .map { params -> SwapTransaction? in
//                    guard let source = params.source,
//                          let destination = params.destination
//                        else {
//                        return nil
//                    }
//
//                    // get decimals
//                    return SwapTransaction(
//                        source: source,
//                        sourceAmount: sourceAmountLamports?.convertToBalance(decimals: source.token.decimals),
//                        destination: destination,
//                        destinationAmount: destinationAmountLamports?.convertToBalance(decimals: destination.token.decimals),
//                        myAccountSymbol: myAccountSymbol
//                    )
//                }
//                .catchAndReturn(nil)
        }
    }
}
