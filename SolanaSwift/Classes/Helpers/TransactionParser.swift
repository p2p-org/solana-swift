//
//  TransactionParser.swift
//  SolanaSwift
//
//  Created by Chung Tran on 06/04/2021.
//

import Foundation
import RxSwift

protocol SolanaSDKTransactionParserType {
    func parse(transactionInfo: SolanaSDK.TransactionInfo) -> Single<SolanaSDKTransactionType>
}

extension SolanaSDK {
    struct TransactionParser: SolanaSDKTransactionParserType {
        // MARK: - Properties
        let solanaSDK: SolanaSDK
        
        // MARK: - Initializers
        init(solanaSDK: SolanaSDK) {
            self.solanaSDK = solanaSDK
        }
        
        // MARK: - Methods
        func parse(transactionInfo: TransactionInfo) -> Single<SolanaSDKTransactionType> {
            // get data
            let innerInstructions = transactionInfo.meta?.innerInstructions
            let instructions = transactionInfo.transaction.message.instructions
            let preBalances = transactionInfo.meta?.preBalances
            let preTokenBalances = transactionInfo.meta?.preTokenBalances
            
            // swap
            if let instructionIndex = getSwapInstructionIndex(instructions: instructions)
            {
                let instruction = instructions[instructionIndex]
                return parseSwapTransaction(index: instructionIndex, instruction: instruction, innerInstructions: innerInstructions)
                    .map {$0 as SolanaSDKTransactionType}
            }
            
            return .error(Error.unknown)
        }
        
        // MARK: - Swap
        private func getSwapInstructionIndex(
            instructions: [ParsedInstruction]
        ) -> Int? {
            instructions.firstIndex(
                where: {
                    $0.programId == solanaSDK.network.swapProgramId.base58EncodedString /*swap v2*/ ||
                        $0.programId == "9qvG1zUp8xF1Bi4m6UdRNby1BAAuaDrUxSpv4CmRRMjL" /*main old swap*/ ||
                        $0.programId == "DjVE6JNiYqPL2QXyCUUh8rNjHrbz9hXHNYt99MQ59qw1" /*main ocra*/
                })
        }
        
        private func parseSwapTransaction(
            index: Int,
            instruction: ParsedInstruction,
            innerInstructions: [InnerInstruction]?
        ) -> Single<SwapTransaction> {
            // get data
            guard let data = instruction.data else {return .just(SwapTransaction.empty)}
            let buf = Base58.decode(data)
            
            // get instruction index
            guard let instructionIndex = buf.first,
                  instructionIndex == 1,
                  let swapInnerInstruction = innerInstructions?.first(where: {$0.index == index})
            else { return .just(SwapTransaction.empty) }
            
            // get instructions
            let transfersInstructions = swapInnerInstruction.instructions.filter {$0.parsed?.type == .transfer}
            guard transfersInstructions.count >= 2 else {return .just(SwapTransaction.empty)}
            
            let sourceInstruction = transfersInstructions[0]
            let destinationInstruction = transfersInstructions[1]
            let sourceInfo = sourceInstruction.parsed?.info
            let destinationInfo = destinationInstruction.parsed?.info
            
            // group request
            var requests = [Single<AccountInfo?>]()
            
            // get source
            var source: PublicKey?
            if let sourceString = sourceInfo?.source {
                source = try? PublicKey(string: sourceString)
                requests.append(
                    getAccountInfo(account: sourceString, retryWithAccount: sourceInfo?.destination)
                )
            }
            
            var destination: PublicKey?
            if let destinationString = destinationInfo?.destination {
                destination = try? PublicKey(string: destinationString)
                requests.append(
                    getAccountInfo(account: destinationString, retryWithAccount: destinationInfo?.source)
                )
            }
            
            var sourceAccountInfo: AccountInfo?
            var destinationAccountInfo: AccountInfo?
            // get token account info
            return Single.zip(requests)
                .flatMap { params -> Single<[Int?]> in
                    // get source, destination account info
                    sourceAccountInfo = params[0]
                    destinationAccountInfo = params[1]
                    
                    // get decimals
                    return Single.zip([
                        getDecimals(mintAddress: sourceAccountInfo?.mint),
                        getDecimals(mintAddress: destinationAccountInfo?.mint)
                    ])
                }
                .map {decimals -> SwapTransaction in
                    let sourceDecimals = decimals[0]
                    let destinationDecimals = decimals[1]
                    
                    let sourceAmount = UInt64(sourceInfo?.amount ?? "0")?.convertToBalance(decimals: sourceDecimals)
                    let destinationAmount = UInt64(destinationInfo?.amount ?? "0")?.convertToBalance(decimals: destinationDecimals)
                    
                    return SwapTransaction(source: source, sourceInfo: sourceAccountInfo, sourceAmount: sourceAmount, destination: destination, destinationInfo: destinationAccountInfo, destinationAmount: destinationAmount)
                }
                .catchAndReturn(SolanaSDK.SwapTransaction(source: source, sourceInfo: sourceAccountInfo, sourceAmount: nil, destination: destination, destinationInfo: destinationAccountInfo, destinationAmount: nil))
            
        }
        
        // MARK: - Helpers
        private func getAccountInfo(account: String, retryWithAccount retryAccount: String? = nil) -> Single<AccountInfo?> {
            solanaSDK.getAccountInfo(
                account: account,
                decodedTo: AccountInfo.self
            )
                .map {$0.data.value}
                .catchAndReturn(nil)
                .flatMap {
                    if $0 == nil,
                       let retryAccount = retryAccount
                    {
                        return getAccountInfo(account: retryAccount)
                    }
                    return .just($0)
                }
        }
        
        private func getMintData(_ mint: PublicKey?) -> Single<Mint?> {
            guard let mint = mint else {return .just(nil)}
            return solanaSDK.getMintData(mintAddress: mint)
                .map {$0 as Mint?}
                .catchAndReturn(nil)
        }
        
        private func getDecimals(mintAddress: PublicKey?) -> Single<Int?> {
            getMintData(mintAddress)
                .map {$0?.decimals}
                .map {Int($0 ?? 0)}
        }
    }
}
