//
//  TransactionParser.swift
//  SolanaSwift
//
//  Created by Chung Tran on 06/04/2021.
//

import Foundation
import RxSwift

public protocol SolanaSDKTransactionParserType {
    func parse(transactionInfo: SolanaSDK.TransactionInfo, myAccount: String?, myAccountSymbol: String?, p2pFeePayerPubkeys: [String]) -> Single<SolanaSDK.ParsedTransaction>
}

public extension SolanaSDK {
    struct TransactionParser: SolanaSDKTransactionParserType {
        // MARK: - Properties
        private let solanaSDK: SolanaSDK
        
        // MARK: - Initializers
        public init(solanaSDK: SolanaSDK) {
            self.solanaSDK = solanaSDK
        }
        
        // MARK: - Methods
        public func parse(
            transactionInfo: TransactionInfo,
            myAccount: String?,
            myAccountSymbol: String?,
            p2pFeePayerPubkeys: [String]
        ) -> Single<ParsedTransaction> {
            // get data
            let innerInstructions = transactionInfo.meta?.innerInstructions
            let instructions = transactionInfo.transaction.message.instructions
            
            // single
            var single: Single<AnyHashable?>
            
            // swap, liquidity (un-parsed type)
            if let instructionIndex = getSwapInstructionIndex(instructions: instructions)
            {
                let checkingInnerInstructions = innerInstructions?.first?.instructions
                // Provide liquidity to pool (unsupported yet)
                if checkingInnerInstructions?.count == 3,
                        checkingInnerInstructions![0].parsed?.type == "transfer",
                        checkingInnerInstructions![1].parsed?.type == "transfer",
                        checkingInnerInstructions![2].parsed?.type == "mintTo"
                {
                    single = .just(nil)
                }
                
                // Later: burn?
                else if checkingInnerInstructions?.count == 3,
                        checkingInnerInstructions![0].parsed?.type == "burn",
                        checkingInnerInstructions![1].parsed?.type == "transfer",
                        checkingInnerInstructions![2].parsed?.type == "transfer"
                {
                    single = .just(nil)
                }
                
                // swap
                else {
                    single = parseSwapTransaction(
                        index: instructionIndex,
                        instructions: instructions,
                        innerInstructions: innerInstructions,
                        postTokenBalances: transactionInfo.meta?.postTokenBalances,
                        myAccountSymbol: myAccountSymbol
                    )
                        .map {$0 as AnyHashable}
                }
            }
            
            // create account
            else if instructions.count == 2,
               instructions.first?.parsed?.type == "createAccount",
               instructions.last?.parsed?.type == "initializeAccount"
            {
                single = parseCreateAccountTransaction(
                    instruction: instructions[0],
                    initializeAccountInstruction: instructions.last
                )
                    .map {$0 as AnyHashable}
            }
            
            // close account
            else if instructions.count == 1,
               instructions.first?.parsed?.type == "closeAccount"
            {
                single = parseCloseAccountTransaction(
                    closedTokenPubkey: instructions.first?.parsed?.info.account,
                    preBalances: transactionInfo.meta?.preBalances,
                    preTokenBalance: transactionInfo.meta?.preTokenBalances?.first
                )
                    .map {$0 as AnyHashable}
            }
            
            // transfer
            else if instructions.count == 1 || instructions.count == 4 || instructions.count == 2,
               instructions.last?.parsed?.type == "transfer" || instructions.last?.parsed?.type == "transferChecked",
               let instruction = instructions.last
            {
                single = parseTransferTransaction(
                    instruction: instruction,
                    postTokenBalances: transactionInfo.meta?.postTokenBalances ?? [],
                    myAccount: myAccount,
                    accountKeys: transactionInfo.transaction.message.accountKeys,
                    p2pFeePayerPubkeys: p2pFeePayerPubkeys
                )
                    .map {$0 as AnyHashable}
            }
            
            // unknown transaction
            else {
                single = .just(nil)
            }
            
            // parse error
            var status = SolanaSDK.ParsedTransaction.Status.confirmed
            if transactionInfo.meta?.err != nil {
                let errorMessage = transactionInfo.meta?.logMessages?
                    .first(where: {$0.contains("Program log: Error:")})?
                    .replacingOccurrences(of: "Program log: Error: ", with: "")
                status = .error(errorMessage)
            }
            
            return single
                .map {
                    ParsedTransaction(
                        status: status,
                        signature: nil,
                        value: $0,
                        slot: nil,
                        blockTime: nil,
                        fee: transactionInfo.meta?.fee,
                        blockhash: transactionInfo.transaction.message.recentBlockhash
                    )
                }
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
            let token = getTokenWithMint(initializeAccountInfo?.mint)
            
            return .just(
                CreateAccountTransaction(
                    fee: fee,
                    newWallet: Wallet(
                        pubkey: info?.newAccount,
                        lamports: nil,
                        token: token
                    )
                )
            )
        }
        
        // MARK: - Close account
        private func parseCloseAccountTransaction(
            closedTokenPubkey: String?,
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
                    closedWallet: Wallet(
                        pubkey: closedTokenPubkey,
                        lamports: nil,
                        token: token
                    )
                )
            )
        }
        
        // MARK: - Transfer
        private func parseTransferTransaction(
            instruction: ParsedInstruction,
            postTokenBalances: [TokenBalance],
            myAccount: String?,
            accountKeys: [Account.Meta],
            p2pFeePayerPubkeys: [String]
        ) -> Single<TransferTransaction>
        {
            // construct wallets
            var source: Wallet?
            var destination: Wallet?
            
            // get pubkeys
            let sourcePubkey = instruction.parsed?.info.source
            let destinationPubkey = instruction.parsed?.info.destination
            
            // get lamports
            let lamports = instruction.parsed?.info.lamports ?? UInt64(instruction.parsed?.info.amount ?? instruction.parsed?.info.tokenAmount?.amount ?? "0")
            
            // SOL to SOL
            let request: Single<TransferTransaction>
            if instruction.programId == PublicKey.programId.base58EncodedString {
                source = Wallet.nativeSolana(pubkey: sourcePubkey, lamport: nil)
                destination = Wallet.nativeSolana(pubkey: destinationPubkey, lamport: nil)
                
                request = .just(
                    TransferTransaction(
                        source: source,
                        destination: destination,
                        authority: instruction.parsed?.info.authority,
                        amount: lamports?.convertToBalance(decimals: source!.token.decimals),
                        myAccount: myAccount
                    )
                )
            } else {
                // SPL to SPL token
                if let tokenBalance = postTokenBalances.first(where: {!$0.mint.isEmpty})
                {
                    let token = getTokenWithMint(tokenBalance.mint)
                    
                    source = Wallet(pubkey: sourcePubkey, lamports: nil, token: token)
                    destination = Wallet(pubkey: destinationPubkey, lamports: nil, token: token)
                    
                    // if the wallet that is opening is SOL, then modify myAccount
                    var myAccount = myAccount
                    if sourcePubkey != myAccount && destinationPubkey != myAccount,
                       accountKeys.count >= 4
                    {
                        // send
                        if myAccount == accountKeys[0].publicKey.base58EncodedString {
                            myAccount = sourcePubkey
                        }
                        
                        if myAccount == accountKeys[3].publicKey.base58EncodedString {
                            myAccount = destinationPubkey
                        }
                    }
                    
                    request = .just(
                        TransferTransaction(
                            source: source,
                            destination: destination,
                            authority: instruction.parsed?.info.authority,
                            amount: lamports?.convertToBalance(decimals: source?.token.decimals),
                            myAccount: myAccount
                        )
                    )
                } else {
                    request = getAccountInfo(account: sourcePubkey, retryWithAccount: destinationPubkey)
                        .map { info in
                            // update source
                            let token = getTokenWithMint(info?.mint.base58EncodedString)
                            source = Wallet(pubkey: sourcePubkey, lamports: nil, token: token)
                            destination = Wallet(pubkey: destinationPubkey, lamports: nil, token: token)
                            
                            return TransferTransaction(
                                source: source,
                                destination: destination,
                                authority: instruction.parsed?.info.authority,
                                amount: lamports?.convertToBalance(decimals: source?.token.decimals),
                                myAccount: myAccount
                            )
                        }
                }
            }
            
            // define if transaction was paid by p2p.org
            return request
                .map { transaction in
                    var transaction = transaction
                    if let payer = accountKeys.map({$0.publicKey}).first?.base58EncodedString,
                       p2pFeePayerPubkeys.contains(payer)
                    {
                        transaction.wasPaidByP2POrg = true
                    }
                    return transaction
                }
        }
        
        // MARK: - Swap
        private func getSwapInstructionIndex(
            instructions: [ParsedInstruction]
        ) -> Int? {
            // ignore liqu
            instructions.firstIndex(
                where: {
                    $0.programId == solanaSDK.endpoint.network.swapProgramId.base58EncodedString /*swap ocra*/ ||
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
            guard index < instructions.count else {return .just(nil)}
            let instruction = instructions[index]
            
            // group request
            var request: Single<(source: Wallet?, destination: Wallet?)>
            var sourceAmountLamports: Lamports?
            var destinationAmountLamports: Lamports?
            
            // check inner instructions
            if let data = instruction.data,
               let instructionIndex = Base58.decode(data).first,
               instructionIndex == 1,
               let swapInnerInstruction = innerInstructions?.first(where: {$0.index == index})
            {
                // get instructions
                let transfersInstructions = swapInnerInstruction.instructions.filter {$0.parsed?.type == "transfer"}
                guard transfersInstructions.count >= 2 else {return .just(nil)}
                
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
                        getAccountInfo(account: sourceString, retryWithAccount: sourceInfo?.destination)
                    )
                }
                
                var destinationPubkey: PublicKey?
                if let destinationString = destinationInfo?.destination {
                    destinationPubkey = try? PublicKey(string: destinationString)
                    accountInfoRequests.append(
                        getAccountInfo(account: destinationString, retryWithAccount: destinationInfo?.source)
                    )
                }
                
                request = Single.zip(accountInfoRequests)
                    .map {params -> (source: Wallet?, destination: Wallet?) in
                        // get source, destination account info
                        let sourceAccountInfo = params[0]
                        let destinationAccountInfo = params[1]
                        
                        // source
                        let sourceToken = getTokenWithMint(sourceAccountInfo?.mint.base58EncodedString)
                        let source = Wallet(
                            pubkey: sourcePubkey?.base58EncodedString,
                            lamports: sourceAccountInfo?.lamports,
                            token: sourceToken
                        )
                        
                        // destination
                        let destinationToken = getTokenWithMint(destinationAccountInfo?.mint.base58EncodedString)
                        let destination = Wallet(
                            pubkey: destinationPubkey?.base58EncodedString,
                            lamports: destinationAccountInfo?.lamports,
                            token: destinationToken
                        )
                        return (source: source, destination: destination)
                    }
                
                sourceAmountLamports = Lamports(sourceInfo?.amount ?? "0")
                destinationAmountLamports = Lamports(destinationInfo?.amount ?? "0")
            }
            
            // check instructions for failed transaction
            else if let approveInstruction = instructions
                        .first(where: {$0.parsed?.type == "approve"}),
                    let sourceAmountString = approveInstruction.parsed?.info.amount,
                    let sourceMint = postTokenBalances?.first?.mint,
                    let destinationMint = postTokenBalances?.last?.mint
            {
                // source wallet
                let source = Wallet(
                    pubkey: approveInstruction.parsed?.info.source,
                    lamports: Lamports(postTokenBalances?.first?.uiTokenAmount.amount ?? "0"),
                    token: getTokenWithMint(sourceMint)
                )
                
                // destination wallet
                var destinationPubkey: String?
                let destinationToken = getTokenWithMint(destinationMint)
                if destinationToken.symbol == "SOL" {
                    destinationPubkey = approveInstruction.parsed?.info.owner
                }
                let destination = Wallet(
                    pubkey: destinationPubkey,
                    lamports: Lamports(postTokenBalances?.last?.uiTokenAmount.amount ?? "0"),
                    token: destinationToken
                )
                
                // form request
                request = .just((source: source, destination: destination))
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
                    else {return nil}
                    
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
        
        // MARK: - Helpers
        private func getTokenWithMint(_ mint: String?) -> Token {
            guard let mint = mint else {return .unsupported(mint: nil)}
            return solanaSDK.supportedTokens.first(where: {$0.address == mint}) ?? .unsupported(mint: mint)
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
    }
}
