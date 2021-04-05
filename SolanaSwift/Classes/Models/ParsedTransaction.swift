//
//  ParsedTransaction.swift
//  SolanaSwift
//
//  Created by Chung Tran on 05/04/2021.
//

import Foundation
import RxSwift

protocol SolanaSDKTransactionType {
    
}

public extension SolanaSDK {
    struct SwapTransaction: SolanaSDKTransactionType {
        let source: PublicKey?
        let sourceTokenAccount: AccountInfo
    }
}

extension SolanaSDK {
    struct TransactionParser {
        // MARK: - Initializers
        static func from(client: SolanaSDK, transactionInfo: TransactionInfo, network: Network) -> Single<SolanaSDKTransactionType> {
            // get data
            let innerInstructions = transactionInfo.meta?.innerInstructions
            let instructions = transactionInfo.transaction.message.instructions
            let preBalances = transactionInfo.meta?.preBalances
            let preTokenBalances = transactionInfo.meta?.preTokenBalances
            
            // swap
            if let instruction = instructions.first(
                where: {
                    $0.programId == network.swapProgramId.base58EncodedString /*swap v2*/ ||
                        $0.programId == "9qvG1zUp8xF1Bi4m6UdRNby1BAAuaDrUxSpv4CmRRMjL" /*main old swap*/ ||
                        $0.programId == "DjVE6JNiYqPL2QXyCUUh8rNjHrbz9hXHNYt99MQ59qw1" /*main ocra*/
                })
            {
                // get data
                guard let data = instruction.data else {return .just(SwapTransaction())}
                let buf = Base58.decode(data)
                
                // get instruction index
                guard let instructionIndex = buf.first,
                      instructionIndex == 1,
                      let swapInnerInstruction = innerInstructions?.first(where: {$0.index == instructionIndex})
                else { return .just(SwapTransaction()) }
                
                // get instructions
                let transfersInstructions = swapInnerInstruction.instructions.filter {$0.parsed?.type == .transfer}
                guard transfersInstructions.count >= 2 else {return .just(SwapTransaction())}
                
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
                        getAccountInfo(client: client, account: sourceString)
                            .flatMap {
                                if $0 == nil,
                                   let destination = sourceInfo?.destination
                                {
                                    return getAccountInfo(client: client, account: destination)
                                }
                                return .just($0)
                            }
                    )
                }
                
                var destination: PublicKey?
                if let destinationString = destinationInfo?.destination {
                    destination = try? PublicKey(string: destinationString)
                    requests.append(
                        getAccountInfo(client: client, account: destinationString)
                            .flatMap {
                                if $0 == nil,
                                   let destination = sourceInfo?.destination
                                {
                                    return getAccountInfo(client: client, account: destination)
                                }
                                return .just($0)
                            }
                    )
                }
                
                // get token account info
                return Single.zip(requests)
                    .map {params in
                        
                    }
                
                // init
                parsedTransaction.type = .swap
                return .just(parsedTransaction)
            }
            
            return nil
        }
        
        private static func getAccountInfo(client: SolanaSDK, account: String) -> Single<AccountInfo?> {
            client.getAccountInfo(
                account: account,
                decodedTo: AccountInfo.self
            )
                .map {$0.data.value}
                .catchAndReturn(nil)
        }
    }
}
