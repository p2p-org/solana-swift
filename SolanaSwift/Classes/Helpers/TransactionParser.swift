//
//  TransactionParser.swift
//  SolanaSwift
//
//  Created by Chung Tran on 06/04/2021.
//

import Foundation
import RxSwift

public protocol SolanaSDKTransactionParserType {
    func parse(signature: String, transactionInfo: SolanaSDK.TransactionInfo, myAccount: String?, myAccountSymbol: String?) -> Single<SolanaSDK.AnyTransaction>
}

public extension SolanaSDK {
    struct TransactionParser: SolanaSDKTransactionParserType {
        // MARK: - Properties
        private let solanaSDK: SolanaSDK
        private let supportedTokens: [Token]
        
        // MARK: - Initializers
        public init(solanaSDK: SolanaSDK) {
            self.solanaSDK = solanaSDK
            supportedTokens = Token.getSupportedTokens(network: solanaSDK.network) ?? []
        }
        
        // MARK: - Methods
        public func parse(
            signature: String,
            transactionInfo: TransactionInfo,
            myAccount: String?,
            myAccountSymbol: String?
        ) -> Single<AnyTransaction> {
            // get data
            let innerInstructions = transactionInfo.meta?.innerInstructions
            let instructions = transactionInfo.transaction.message.instructions
            
            // swap (un-parsed type)
            if let instructionIndex = getSwapInstructionIndex(instructions: instructions)
            {
                let instruction = instructions[instructionIndex]
                return parseSwapTransaction(
                    index: instructionIndex,
                    instruction: instruction,
                    innerInstructions: innerInstructions,
                    myAccountSymbol: myAccountSymbol
                )
                    .map {
                        AnyTransaction(signature: signature, value: $0)
                    }
            }
            
            // create account
            if instructions.count == 2,
               instructions.first?.parsed?.type == "createAccount",
               instructions.last?.parsed?.type == "initializeAccount"
            {
                return parseCreateAccountTransaction(
                    instruction: instructions[0],
                    initializeAccountInstruction: instructions.last
                )
                    .map {
                        AnyTransaction(signature: signature, value: $0)
                    }
            }
            
            // close account
            if instructions.count == 1,
               instructions.first?.parsed?.type == "closeAccount"
            {
                return parseCloseAccountTransaction(
                    preBalances: transactionInfo.meta?.preBalances,
                    preTokenBalance: transactionInfo.meta?.preTokenBalances?.first
                )
                    .map {
                        AnyTransaction(signature: signature, value: $0)
                    }
            }
            
            // transfer
            if instructions.count == 1 || instructions.count == 4,
               instructions.last?.parsed?.type == "transfer",
               let instruction = instructions.last
            {
                return parseTransferTransaction(
                    instruction: instruction,
                    postTokenBalances: transactionInfo.meta?.postTokenBalances ?? [],
                    myAccount: myAccount
                )
                    .map {
                        AnyTransaction(signature: signature, value: $0)
                    }
            }
            
            return .just(
                AnyTransaction(signature: signature, value: nil)
            )
        }
        
        // MARK: - Create account
        private func parseCreateAccountTransaction(
            instruction: ParsedInstruction,
            initializeAccountInstruction: ParsedInstruction?
        ) -> Single<CreateAccountTransaction>
        {
            let info = instruction.parsed?.info
            let initializeAccountInfo = initializeAccountInstruction?.parsed?.info
            
            let fee = info?.lamports?.convertToBalance(decimals: Decimals.SOL)
            var token = getTokenWithMint(initializeAccountInfo?.mint)
            token?.pubkey = info?.newAccount
            return .just(
                CreateAccountTransaction(
                    fee: fee,
                    newToken: token
                )
            )
        }
        
        // MARK: - Close account
        private func parseCloseAccountTransaction(
            preBalances: [Lamports]?,
            preTokenBalance: TokenBalance?
        ) -> Single<CloseAccountTransaction>
        {
            var reimbursedAmountLamports: Lamports?
            
            if (preBalances?.count ?? 0) > 1 {
                reimbursedAmountLamports = preBalances![1]
            }
            
            let reimbursedAmount = reimbursedAmountLamports?.convertToBalance(decimals: Decimals.SOL)
            let token = getTokenWithMint(preTokenBalance?.mint)
            
            return .just(
                CloseAccountTransaction(
                    reimbursedAmount: reimbursedAmount,
                    closedToken: token
                )
            )
        }
        
        // MARK: - Transfer
        private func parseTransferTransaction(
            instruction: ParsedInstruction,
            postTokenBalances: [TokenBalance],
            myAccount: String?
        ) -> Single<TransferTransaction>
        {
            var source: Token?
            var destination: Token?
            
            let sourcePubkey = instruction.parsed?.info.source
            let destinationPubkey = instruction.parsed?.info.destination
            
            let lamports = instruction.parsed?.info.lamports ?? UInt64(instruction.parsed?.info.amount ?? "0")
            
            // SOL to SOL
            if instruction.programId == PublicKey.programId.base58EncodedString {
                source = getSOLToken()
                source?.pubkey = sourcePubkey
                source?.decimals = Int(Decimals.SOL)
                
                destination = getSOLToken()
                destination?.pubkey = destinationPubkey
                destination?.decimals = Int(Decimals.SOL)
                
                return .just(
                    TransferTransaction(
                        source: source,
                        destination: destination,
                        amount: lamports?.convertToBalance(decimals: source?.decimals),
                        myAccount: myAccount
                    )
                )
            } else {
                // SPL to SPL token
                var mintRequest: Single<String?>
                
                if let tokenBalance = postTokenBalances.first(where: {!$0.mint.isEmpty})
                {
                    source = getTokenWithMint(tokenBalance.mint)
                    source?.pubkey = sourcePubkey
                    
                    destination = getTokenWithMint(tokenBalance.mint)
                    destination?.pubkey = destinationPubkey
                    
                    mintRequest = .just(tokenBalance.mint)
                } else {
                    mintRequest = getAccountInfo(account: sourcePubkey, retryWithAccount: destinationPubkey)
                        .map { info in
                            // update source
                            source = getTokenWithMint(info?.mint.base58EncodedString)
                            source?.pubkey = sourcePubkey
                            
                            // update destination
                            destination = getTokenWithMint(info?.mint.base58EncodedString)
                            destination?.pubkey = destinationPubkey
                            
                            return info?.mint.base58EncodedString
                        }
                }
                return mintRequest
                    .flatMap { mint -> Single<Decimals?> in
                        guard let mint = try? PublicKey(string: mint) else {
                            return .just(nil)
                        }
                        return self.getDecimals(mintAddress: mint)
                    }
                    .map { decimals -> TransferTransaction in
                        source?.decimals = Int(decimals ?? 0)
                        destination?.decimals = Int(decimals ?? 0)
                        
                        return TransferTransaction(
                            source: source,
                            destination: destination,
                            amount: lamports?.convertToBalance(decimals: decimals),
                            myAccount: myAccount
                        )
                    }
                    .catchAndReturn(
                        TransferTransaction(
                            source: source,
                            destination: destination,
                            amount: nil,
                            myAccount: myAccount
                        )
                    )
            }
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
            innerInstructions: [InnerInstruction]?,
            myAccountSymbol: String?
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
            let transfersInstructions = swapInnerInstruction.instructions.filter {$0.parsed?.type == "transfer"}
            guard transfersInstructions.count >= 2 else {return .just(SwapTransaction.empty)}
            
            let sourceInstruction = transfersInstructions[0]
            let destinationInstruction = transfersInstructions[1]
            let sourceInfo = sourceInstruction.parsed?.info
            let destinationInfo = destinationInstruction.parsed?.info
            
            // group request
            var requests = [Single<AccountInfo?>]()
            
            // get source
            var sourcePubkey: PublicKey?
            if let sourceString = sourceInfo?.source {
                sourcePubkey = try? PublicKey(string: sourceString)
                requests.append(
                    getAccountInfo(account: sourceString, retryWithAccount: sourceInfo?.destination)
                )
            }
            
            var destinationPubkey: PublicKey?
            if let destinationString = destinationInfo?.destination {
                destinationPubkey = try? PublicKey(string: destinationString)
                requests.append(
                    getAccountInfo(account: destinationString, retryWithAccount: destinationInfo?.source)
                )
            }
            
            var source: Token?
            var destination: Token?
            
            // get token account info
            return Single.zip(requests)
                .flatMap { params -> Single<[Decimals?]> in
                    // get source, destination account info
                    let sourceAccountInfo = params[0]
                    let destinationAccountInfo = params[1]
                    
                    // update token
                    source = getTokenWithMint(sourceAccountInfo?.mint.base58EncodedString)
                    source?.pubkey = sourcePubkey?.base58EncodedString
                    
                    destination = getTokenWithMint(destinationAccountInfo?.mint.base58EncodedString)
                    destination?.pubkey = destinationPubkey?.base58EncodedString
                    
                    // get decimals
                    return Single.zip([
                        getDecimals(mintAddress: sourceAccountInfo?.mint),
                        getDecimals(mintAddress: destinationAccountInfo?.mint)
                    ])
                }
                .map {decimals -> SwapTransaction in
                    // get decimals
                    let sourceDecimals = decimals[0]
                    let destinationDecimals = decimals[1]
                    
                    // update token
                    source?.decimals = Int(sourceDecimals ?? 0)
                    destination?.decimals = Int(destinationDecimals ?? 0)
                    
                    // update amount
                    let sourceAmount = UInt64(sourceInfo?.amount ?? "0")?.convertToBalance(decimals: sourceDecimals)
                    let destinationAmount = UInt64(destinationInfo?.amount ?? "0")?.convertToBalance(decimals: destinationDecimals)
                    
                    // construct SwapInstruction
                    return SwapTransaction(
                        source: source,
                        sourceAmount: sourceAmount,
                        destination: destination,
                        destinationAmount: destinationAmount,
                        myAccountSymbol: myAccountSymbol
                    )
                }
                .catchAndReturn(
                    SolanaSDK.SwapTransaction(
                        source: source,
                        sourceAmount: nil,
                        destination: destination,
                        destinationAmount: nil,
                        myAccountSymbol: myAccountSymbol
                    )
                )
        }
        
        // MARK: - Helpers
        private func getTokenWithMint(_ mint: String?) -> Token? {
            guard var mint = mint else {return nil}
            if mint == PublicKey.wrappedSOLMint.base58EncodedString {
                mint = ""
            }
            return supportedTokens.first(where: {$0.mintAddress == mint})
        }
        
        private func getSOLToken() -> Token {
            supportedTokens.first(where: {$0.mintAddress.isEmpty})!
        }
        
        private func getAccountInfo(account: String?, retryWithAccount retryAccount: String? = nil) -> Single<AccountInfo?> {
            guard let account = account else {return .just(nil)}
            return solanaSDK.getAccountInfo(
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
        
        private func getDecimals(mintAddress: PublicKey?) -> Single<Decimals?> {
            getMintData(mintAddress)
                .map {$0?.decimals}
        }
    }
}
