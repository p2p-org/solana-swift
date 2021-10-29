//
// Created by Giang Long Tran on 29.10.21.
//

import Foundation
import RxSwift

public extension SolanaSDK {
    
    /**
     Use this class only for testing purpose.
     */
    struct OldOrcaSwapParserImpl: OrcaSwapParser {
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
                return parseSwapTransaction(
                    index: getOrcaSwapInstructionIndex(instructions: transactionInfo.transaction.message.instructions)!,
                    instructions: transactionInfo.transaction.message.instructions,
                    innerInstructions: transactionInfo.meta?.innerInstructions,
                    postTokenBalances: transactionInfo.meta?.postTokenBalances,
                    myAccountSymbol: myAccountSymbol
                )
            }
        }
    
        private func getOrcaSwapInstructionIndex(
            instructions: [ParsedInstruction]
        ) -> Int? {
            // ignore liqu
            instructions.firstIndex(
                where: {
                    $0.programId == PublicKey.orcaSwapId(version: 1).base58EncodedString /*swap ocra*/ ||
                        $0.programId == PublicKey.orcaSwapId(version: 2).base58EncodedString /*swap ocra*/ ||
                        $0.programId == "9qvG1zUp8xF1Bi4m6UdRNby1BAAuaDrUxSpv4CmRRMjL" /*main deprecated*/ ||
                        $0.programId == "SwaPpA9LAaLfeLi3a68M4DjnLqgtticKg6CnyNwgAC8" /*main deprecated*/
                })
        }
    
        private func parseSwapTransaction(
            index: Int,
            instructions: [ParsedInstruction],
            innerInstructions: [InnerInstruction]?,
            postTokenBalances: [TokenBalance]?,
            myAccountSymbol: String?
        ) -> Single<SwapTransaction?> {
            // get instruction
            guard index < instructions.count else {
                return .just(nil)
            }
            let instruction = instructions[index]
        
            // group request
            var request: Single<(source: Wallet?, destination: Wallet?)>
            var sourceAmountLamports: Lamports?
            var destinationAmountLamports: Lamports?
        
            // check inner instructions
            if let data = instruction.data,
               let instructionIndex = Base58.decode(data).first,
               instructionIndex == 1,
               let swapInnerInstruction = innerInstructions?.first(where: { $0.index == index }) {
                // get instructions
                let transfersInstructions = swapInnerInstruction.instructions.filter {
                    $0.parsed?.type == "transfer"
                }
                guard transfersInstructions.count >= 2 else {
                    return .just(nil)
                }
            
                let sourceInstruction = transfersInstructions[0]
                let destinationInstruction = transfersInstructions[1]
            
                let sourceInfo = sourceInstruction.parsed?.info
                let destinationInfo = destinationInstruction.parsed?.info
            
                // get source
                var accountInfoRequests = [Single<AccountInfo?>]()
                var sourcePubkey: PublicKey?
                if let sourceString = sourceInfo?.source {
                    sourcePubkey = try? PublicKey(string: sourceString)
                    accountInfoRequests.append(
                        solanaSDK.getAccountInfo(account: sourceString, retryWithAccount: sourceInfo?.destination)
                    )
                }
            
                var destinationPubkey: PublicKey?
                if let destinationString = destinationInfo?.destination {
                    destinationPubkey = try? PublicKey(string: destinationString)
                    accountInfoRequests.append(
                        solanaSDK.getAccountInfo(account: destinationString, retryWithAccount: destinationInfo?.source)
                    )
                }
            
                request = Single.zip(accountInfoRequests)
                    .flatMap { params -> Single<(source: Wallet?, destination: Wallet?)> in
                        // get source, destination account info
                        let sourceAccountInfo = params[0]
                        let destinationAccountInfo = params[1]
                    
                        return Single.zip(
                                solanaSDK.getTokenWithMint(sourceAccountInfo?.mint.base58EncodedString),
                                solanaSDK.getTokenWithMint(destinationAccountInfo?.mint.base58EncodedString)
                            )
                            .map { sourceToken, destinationToken in
                                let source = Wallet(
                                    pubkey: sourcePubkey?.base58EncodedString,
                                    lamports: sourceAccountInfo?.lamports,
                                    token: sourceToken
                                )
                                let destination = Wallet(
                                    pubkey: destinationPubkey?.base58EncodedString,
                                    lamports: destinationAccountInfo?.lamports,
                                    token: destinationToken
                                )
                                return (source: source, destination: destination)
                            }
                    }
            
                sourceAmountLamports = Lamports(sourceInfo?.amount ?? "0")
                destinationAmountLamports = Lamports(destinationInfo?.amount ?? "0")
            }
        
            // check instructions for failed transaction
            else if let approveInstruction = instructions
                .first(where: { $0.parsed?.type == "approve" }),
                    let sourceAmountString = approveInstruction.parsed?.info.amount,
                    let sourceMint = postTokenBalances?.first?.mint,
                    let destinationMint = postTokenBalances?.last?.mint {
                // form request
                request = Single.zip(
                        solanaSDK.getTokenWithMint(sourceMint),
                        solanaSDK.getTokenWithMint(destinationMint)
                    )
                    .map { sourceToken, destinationToken in
                        let source = Wallet(
                            pubkey: approveInstruction.parsed?.info.source,
                            lamports: Lamports(postTokenBalances?.first?.uiTokenAmount.amount ?? "0"),
                            token: sourceToken
                        )
                        var destinationPubkey: String?
                    
                        if destinationToken.symbol == "SOL" {
                            destinationPubkey = approveInstruction.parsed?.info.owner
                        }
                        let destination = Wallet(
                            pubkey: destinationPubkey,
                            lamports: Lamports(postTokenBalances?.last?.uiTokenAmount.amount ?? "0"),
                            token: destinationToken
                        )
                        return (source: source, destination: destination)
                    }
            
                sourceAmountLamports = Lamports(sourceAmountString)
                destinationAmountLamports = nil // because of the error
            }
        
            // unknown
            else {
                return .just(nil)
            }
        
            // get token account info
            return request
                .map { params -> SwapTransaction? in
                    guard let source = params.source,
                          let destination = params.destination
                        else {
                        return nil
                    }
                
                    // get decimals
                    return SwapTransaction(
                        source: source,
                        sourceAmount: sourceAmountLamports?.convertToBalance(decimals: source.token.decimals),
                        destination: destination,
                        destinationAmount: destinationAmountLamports?.convertToBalance(decimals: destination.token.decimals),
                        myAccountSymbol: myAccountSymbol
                    )
                }
                .catchAndReturn(nil)
        }
    }
}
