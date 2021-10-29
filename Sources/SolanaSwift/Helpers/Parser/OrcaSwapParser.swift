//
// Created by Giang Long Tran on 29.10.21.
//

import Foundation
import RxSwift

public protocol OrcaSwapParser {
    func can(instructions: [SolanaSDK.ParsedInstruction]) -> Bool
    func parse(transactionInfo: SolanaSDK.TransactionInfo, myAccountSymbol: String?) -> Single<SolanaSDK.SwapTransaction?>
}

public extension SolanaSDK {
    
    struct OrcaSwapParserImpl: OrcaSwapParser {
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
        public func can(instructions: [ParsedInstruction]) -> Bool {
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
        
        public func parse(transactionInfo: TransactionInfo, myAccountSymbol: String?) -> Single<SwapTransaction?> {
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
            
            // A swap should have at lease one orca instruction.
            guard swapInstructions.count > 0 else {
                return parseFailedTransaction(transactionInfo: transactionInfo, myAccountSymbol: myAccountSymbol)
            }
            
            // Get source and target (It can be user's public key, amount of transfer, ...)
            guard let source = swapInstructions.first?.innerInstruction?.instructions.first,
                  let destination = swapInstructions.last?.innerInstruction?.instructions.last else {
                return parseFailedTransaction(transactionInfo: transactionInfo, myAccountSymbol: myAccountSymbol)
            }
            
            let sourceInfo = source.parsed?.info
            let destinationInfo = destination.parsed?.info
            
            return Single.zip(
                solanaSDK.getAccountInfo(account: sourceInfo?.source, retryWithAccount: sourceInfo?.destination),
                solanaSDK.getAccountInfo(account: destinationInfo?.destination, retryWithAccount: destinationInfo?.source)
            ).flatMap { accounts in
                // Creating a wallets that are based on account infos
                Single.zip(
                    solanaSDK.getTokenWithMint(accounts.0?.mint.base58EncodedString),
                    solanaSDK.getTokenWithMint(accounts.1?.mint.base58EncodedString)
                ).map { tokens in
                    (
                        Wallet(
                            pubkey: try? PublicKey(string: sourceInfo?.source).base58EncodedString,
                            lamports: accounts.0?.lamports,
                            token: tokens.0
                        ),
                        Wallet(
                            pubkey: try? PublicKey(string: destinationInfo?.destination).base58EncodedString,
                            lamports: accounts.1?.lamports,
                            token: tokens.1
                        )
                    )
                }
            }.flatMap { wallets -> Single<SwapTransaction?> in
                // Return Swap transaction
                
                let sourceAmountLamports = Lamports(sourceInfo?.amount ?? "0")
                let destinationAmountLamports = Lamports(destinationInfo?.amount ?? "0")
                
                // get decimals
                return .just(
                    SwapTransaction(
                        source: wallets.0,
                        sourceAmount: sourceAmountLamports?.convertToBalance(decimals: wallets.0.token.decimals),
                        destination: wallets.1,
                        destinationAmount: destinationAmountLamports?.convertToBalance(decimals: wallets.1.token.decimals),
                        myAccountSymbol: myAccountSymbol
                    )
                )
            }.catchAndReturn(nil)
        }
        
        func parseFailedTransaction(transactionInfo: TransactionInfo, myAccountSymbol: String?) -> Single<SwapTransaction?> {
            guard let postTokenBalances = transactionInfo.meta?.postTokenBalances,
                  let approveInstruction = transactionInfo.transaction.message.instructions.first(where: { $0.parsed?.type == "approve" }),
                  let sourceAmountString = approveInstruction.parsed?.info.amount,
                  let sourceMint = postTokenBalances.first?.mint,
                  let destinationMint = postTokenBalances.last?.mint else {
                return .just(nil)
            }
            
            return Single.zip(
                    solanaSDK.getTokenWithMint(sourceMint),
                    solanaSDK.getTokenWithMint(destinationMint)
                )
                .map { sourceToken, destinationToken -> (source: Wallet, destination: Wallet) in
                    let source = Wallet(
                        pubkey: approveInstruction.parsed?.info.source,
                        lamports: Lamports(postTokenBalances.first?.uiTokenAmount.amount ?? "0"),
                        token: sourceToken
                    )
                    var destinationPubkey: String?
                    
                    if destinationToken.symbol == "SOL" {
                        destinationPubkey = approveInstruction.parsed?.info.owner
                    }
                    let destination = Wallet(
                        pubkey: destinationPubkey,
                        lamports: Lamports(postTokenBalances.last?.uiTokenAmount.amount ?? "0"),
                        token: destinationToken
                    )
                    return (source: source, destination: destination)
                }.flatMap { wallets -> Single<SwapTransaction?> in
                    let source = wallets.0
                    let destination = wallets.1
                    let sourceAmountLamports = Lamports(sourceAmountString)
                    
                    // get decimals
                    return .just(
                        SwapTransaction(
                            source: source,
                            sourceAmount: sourceAmountLamports?.convertToBalance(decimals: source.token.decimals),
                            destination: destination,
                            destinationAmount: nil,
                            myAccountSymbol: myAccountSymbol
                        )
                    )
                }.catchAndReturn(nil)
        }
    }
}
