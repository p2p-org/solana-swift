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
        private let orcaSwapParser: OrcaSwapParser
        
        // MARK: - Initializers
        public init(solanaSDK: SolanaSDK, orcaSwapParser: OrcaSwapParser? = nil) {
            self.solanaSDK = solanaSDK
            self.orcaSwapParser = orcaSwapParser ?? SolanaSDK.OrcaSwapParserImpl(solanaSDK: solanaSDK)
        }
        
        // MARK: - Methods
        public func parse(
                transactionInfo: TransactionInfo,
                myAccount: String?,
                myAccountSymbol: String?,
                p2pFeePayerPubkeys: [String]
        ) -> Single<ParsedTransaction> {
            // get data
            let instructions = transactionInfo.transaction.message.instructions
            
            // single
            var single: Single<AnyHashable?>
            
            switch (true) {
            
            case orcaSwapParser.can(instructions: instructions):
                single = orcaSwapParser.parse(transactionInfo: transactionInfo, myAccountSymbol: myAccountSymbol)
                    .map({ $0 == nil ? nil : $0 as AnyHashable })
            
            case isSerumSwapInstruction(instructions: instructions):
                single = parseSerumSwapTransaction(
                        swapInstructionIndex: getSerumSwapInstructionIndex(instructions: instructions)!,
                        instructions: instructions,
                        preTokenBalances: transactionInfo.meta?.preTokenBalances,
                        innerInstruction: transactionInfo.meta?.innerInstructions?
                                .first(where: { $0.instructions.contains(where: { $0.programId == PublicKey.serumSwapPID.base58EncodedString }) }),
                        myAccountSymbol: myAccountSymbol
                ).map({ $0 == nil ? nil : $0 as AnyHashable })
            
            case isCreateAccountTransaction(instructions: instructions):
                single = parseCreateAccountTransaction(instructions: instructions).map({ $0 as AnyHashable })
            
            case isCloseAccountTransaction(instructions: instructions):
                single = parseCloseAccountTransaction(
                        closedTokenPubkey: instructions.first?.parsed?.info.account,
                        preBalances: transactionInfo.meta?.preBalances,
                        preTokenBalance: transactionInfo.meta?.preTokenBalances?.first
                ).map({ $0 as AnyHashable })
            
            case isTransferTransaction(instructions: instructions):
                single = parseTransferTransaction(
                        instructions: instructions,
                        postTokenBalances: transactionInfo.meta?.postTokenBalances ?? [],
                        myAccount: myAccount,
                        accountKeys: transactionInfo.transaction.message.accountKeys,
                        p2pFeePayerPubkeys: p2pFeePayerPubkeys
                ).map({ $0 as AnyHashable })
            
            default:
                single = .just(nil)
            }
            
            // parse error
            var status = SolanaSDK.ParsedTransaction.Status.confirmed
            if transactionInfo.meta?.err != nil {
                let errorMessage = transactionInfo.meta?.logMessages?
                        .first(where: { $0.contains("Program log: Error:") })?
                        .replacingOccurrences(of: "Program log: Error: ", with: "")
                status = .error(errorMessage)
            }
            
            return single.map({
                ParsedTransaction(
                        status: status,
                        signature: nil,
                        value: $0,
                        slot: nil,
                        blockTime: nil,
                        fee: transactionInfo.meta?.fee,
                        blockhash: transactionInfo.transaction.message.recentBlockhash
                )
            })
        }
        
        // MARK: - Create account
        /**
         Check if transaction is create account transaction
         */
        private func isCreateAccountTransaction(instructions: [ParsedInstruction]) -> Bool {
            switch (instructions.count) {
            case 1: return instructions[0].program == "spl-associated-token-account"
            case 2: return instructions.first?.parsed?.type == "createAccount" && instructions.last?.parsed?.type == "initializeAccount"
            default: return false
            }
        }
        
        private func parseCreateAccountTransaction(
                instructions: [ParsedInstruction]
        ) -> Single<CreateAccountTransaction> {
            if let program = instructions.getFirstProgram(with: "spl-associated-token-account") {
                return solanaSDK.getTokenWithMint(program.parsed?.info.mint).map { token in
                    CreateAccountTransaction(
                            fee: nil,
                            newWallet: Wallet(
                                    pubkey: program.parsed?.info.account,
                                    token: token
                            )
                    )
                }
            } else {
                let info = instructions[0].parsed?.info
                let initializeAccountInfo = instructions.last?.parsed?.info
                
                let fee = info?.lamports?.convertToBalance(decimals: Decimals.SOL)
                return solanaSDK.getTokenWithMint(initializeAccountInfo?.mint)
                        .map { token in
                            CreateAccountTransaction(
                                    fee: fee,
                                    newWallet: Wallet(
                                            pubkey: info?.newAccount,
                                            lamports: nil,
                                            token: token
                                    )
                            )
                        }
            }
        }
        
        // MARK: - Close account
        private func isCloseAccountTransaction(instructions: [ParsedInstruction]) -> Bool {
            switch (instructions.count) {
            case 1: return instructions.first?.parsed?.type == "closeAccount"
            default: return false
            }
        }
        
        private func parseCloseAccountTransaction(
                closedTokenPubkey: String?,
                preBalances: [Lamports]?,
                preTokenBalance: TokenBalance?
        ) -> Single<CloseAccountTransaction> {
            var reimbursedAmountLamports: Lamports?
            
            if (preBalances?.count ?? 0) > 1 {
                reimbursedAmountLamports = preBalances![1]
            }
            
            let reimbursedAmount = reimbursedAmountLamports?.convertToBalance(decimals: Decimals.SOL)
            return solanaSDK.getTokenWithMint(preTokenBalance?.mint)
                    .map { token in
                        CloseAccountTransaction(
                                reimbursedAmount: reimbursedAmount,
                                closedWallet: Wallet(
                                        pubkey: closedTokenPubkey,
                                        lamports: nil,
                                        token: token
                                )
                        )
                    }
        }
        
        // MARK: - Transfer
        /**
         Check is transaction is transfer transaction
         */
        private func isTransferTransaction(instructions: [ParsedInstruction]) -> Bool {
            (instructions.count == 1 || instructions.count == 4 || instructions.count == 2) &&
                    (instructions.last?.parsed?.type == "transfer" || instructions.last?.parsed?.type == "transferChecked")
        }
        
        private func parseTransferTransaction(
                instructions: [ParsedInstruction],
                postTokenBalances: [TokenBalance],
                myAccount: String?,
                accountKeys: [Account.Meta],
                p2pFeePayerPubkeys: [String]
        ) -> Single<TransferTransaction> {
            // get pubkeys
            let transferInstruction = instructions.last
            let sourcePubkey = transferInstruction?.parsed?.info.source
            let destinationPubkey = transferInstruction?.parsed?.info.destination
            
            // get lamports
            let lamports = transferInstruction?.parsed?.info.lamports ?? UInt64(transferInstruction?.parsed?.info.amount ?? transferInstruction?.parsed?.info.tokenAmount?.amount ?? "0")
            
            // SOL to SOL
            let request: Single<TransferTransaction>
            if transferInstruction?.programId == PublicKey.programId.base58EncodedString {
                let source = Wallet.nativeSolana(pubkey: sourcePubkey, lamport: nil)
                let destination = Wallet.nativeSolana(pubkey: destinationPubkey, lamport: nil)
                
                request = .just(
                        TransferTransaction(
                                source: source,
                                destination: destination,
                                authority: nil,
                                destinationAuthority: nil,
                                amount: lamports?.convertToBalance(decimals: source.token.decimals),
                                myAccount: myAccount
                        )
                )
            }
            
            // SPL to SPL token
            else {
                request = parseTransferSPLToSPLTokenTransaction(
                        instructions: instructions,
                        postTokenBalances: postTokenBalances,
                        myAccount: myAccount,
                        accountKeys: accountKeys,
                        sourcePubkey: sourcePubkey,
                        destinationPubkey: destinationPubkey,
                        authority: transferInstruction?.parsed?.info.authority,
                        lamports: lamports
                )
            }
            
            // define if transaction was paid by p2p.org
            return request
                    .map { transaction in
                var transaction = transaction
                if let payer = accountKeys.map({ $0.publicKey }).first?.base58EncodedString,
                   p2pFeePayerPubkeys.contains(payer) {
                    transaction.wasPaidByP2POrg = true
                }
                return transaction
            }
        }
        
        private func parseTransferSPLToSPLTokenTransaction(
                instructions: [ParsedInstruction],
                postTokenBalances: [TokenBalance],
                myAccount: String?,
                accountKeys: [Account.Meta],
                sourcePubkey: String?,
                destinationPubkey: String?,
                authority: String?,
                lamports: Lamports?
        ) -> Single<TransferTransaction> {
            // Get destinationAuthority
            var destinationAuthority: String?
            if let createATokenInstruction = instructions.first(where: { $0.programId == PublicKey.splAssociatedTokenAccountProgramId.base58EncodedString }) {
                // send to associated token
                destinationAuthority = createATokenInstruction.parsed?.info.wallet
            } else if let initializeAccountInstruction = instructions.first(where: { $0.programId == PublicKey.tokenProgramId.base58EncodedString && $0.parsed?.type == "initializeAccount" }) {
                // send to new token address (deprecated)
                destinationAuthority = initializeAccountInstruction.parsed?.info.owner
            }
            
            // Define token with mint
            let request: Single<TransferTransaction>
            if let tokenBalance = postTokenBalances.first(where: { !$0.mint.isEmpty }) {
                // if the wallet that is opening is SOL, then modify myAccount
                var myAccount = myAccount
                if sourcePubkey != myAccount && destinationPubkey != myAccount,
                   accountKeys.count >= 4 {
                    // send
                    if myAccount == accountKeys[0].publicKey.base58EncodedString {
                        myAccount = sourcePubkey
                    }
                    
                    if myAccount == accountKeys[3].publicKey.base58EncodedString {
                        myAccount = destinationPubkey
                    }
                }
                
                request = solanaSDK.getTokenWithMint(tokenBalance.mint)
                        .map { token in
                            let source = Wallet(pubkey: sourcePubkey, lamports: nil, token: token)
                            let destination = Wallet(pubkey: destinationPubkey, lamports: nil, token: token)
                            return TransferTransaction(
                                    source: source,
                                    destination: destination,
                                    authority: authority,
                                    destinationAuthority: destinationAuthority,
                                    amount: lamports?.convertToBalance(decimals: source.token.decimals),
                                    myAccount: myAccount
                            )
                        }
            }
            
            // Mint not found, retrieve mint
            else {
                request = solanaSDK.getAccountInfo(account: sourcePubkey, retryWithAccount: destinationPubkey)
                        .flatMap { info in
                            solanaSDK.getTokenWithMint(info?.mint.base58EncodedString)
                                    .map { token in
                                        let source = Wallet(pubkey: sourcePubkey, lamports: nil, token: token)
                                        let destination = Wallet(pubkey: destinationPubkey, lamports: nil, token: token)
                                        
                                        return TransferTransaction(
                                                source: source,
                                                destination: destination,
                                                authority: authority,
                                                destinationAuthority: destinationAuthority,
                                                amount: lamports?.convertToBalance(decimals: source.token.decimals),
                                                myAccount: myAccount
                                        )
                                    }
                        }
            }
            
            return request
                    .flatMap { transaction -> Single<TransferTransaction> in
                if transaction.destinationAuthority != nil {
                    return .just(transaction)
                }
                guard let account = transaction.destination?.pubkey else {
                    return .just(transaction)
                }
                return solanaSDK.getAccountInfo(account: account)
                        .map {
                            $0?.owner.base58EncodedString
                        }
                        .catchAndReturn(nil)
                        .map {
                            TransferTransaction(
                                    source: transaction.source,
                                    destination: transaction.destination,
                                    authority: transaction.authority,
                                    destinationAuthority: $0,
                                    amount: transaction.amount,
                                    myAccount: myAccount
                            )
                        }
            }
        }
        
        // MARK: - Serum swap
        
        /**
         Check if transaction is a serum swap transaction
         - Parameter instructions: instructions in transaction
         */
        private func isSerumSwapInstruction(instructions: [ParsedInstruction]) -> Bool {
            getSerumSwapInstructionIndex(instructions: instructions) != nil
        }
        
        private func getSerumSwapInstructionIndex(
                instructions: [ParsedInstruction]
        ) -> Int? {
            // ignore liqu
            instructions.lastIndex(
                    where: {
                        $0.programId == PublicKey.serumSwapPID.base58EncodedString
                    }
            )
        }
        
        private func parseSerumSwapTransaction(
                swapInstructionIndex: Int,
                instructions: [ParsedInstruction],
                preTokenBalances: [TokenBalance]?,
                innerInstruction: InnerInstruction?,
                myAccountSymbol: String?
        ) -> Single<SwapTransaction?> {
            // get swapInstruction
            guard let swapInstruction = instructions[safe: swapInstructionIndex]
                    else {
                return .just(nil)
            }
            
            // get all mints
            guard var mints = preTokenBalances?.map({ $0.mint }).unique,
                  mints.count >= 2 // max: 3
                    else {
                return .just(nil)
            }
            
            // transitive swap: remove usdc or usdt if exists
            if mints.count == 3 {
                mints.removeAll(where: { $0.isUSDxMint })
            }
            
            // define swap type
            let isTransitiveSwap = !mints.contains(where: { $0.isUSDxMint })
            
            // assert
            guard let accounts = swapInstruction.accounts
                    else {
                return .just(nil)
            }
            
            if isTransitiveSwap && accounts.count != 27 {
                return .just(nil)
            }
            
            if !isTransitiveSwap && accounts.count != 16 {
                return .just(nil)
            }
            
            // get from and to address
            var fromAddress: String
            var toAddress: String
            
            if isTransitiveSwap { // transitive
                fromAddress = accounts[6]
                toAddress = accounts[21]
            } else { // direct
                fromAddress = accounts[10]
                toAddress = accounts[12]
                
                if mints.first?.isUSDxMint == true && mints.last?.isUSDxMint == false {
                    Swift.swap(&fromAddress, &toAddress)
                }
            }
            
            // amounts
            var fromAmount: Lamports?
            var toAmount: Lamports?
            
            // from amount
            if let instruction = innerInstruction?.instructions
                    .first(where: { $0.parsed?.type == "transfer" && $0.parsed?.info.source == fromAddress }),
               let amountString = instruction.parsed?.info.amount,
               let amount = Lamports(amountString) {
                fromAmount = amount
            }
            
            // to amount
            if let instruction = innerInstruction?.instructions
                    .first(where: { $0.parsed?.type == "transfer" && $0.parsed?.info.destination == toAddress }),
               let amountString = instruction.parsed?.info.amount,
               let amount = Lamports(amountString) {
                toAmount = amount
            }
            
            // if swap from native sol, detect if from or to address is a new account
            if let createAccountInstruction = instructions
                    .first(where: {
                $0.parsed?.type == "createAccount" &&
                        $0.parsed?.info.newAccount == fromAddress
            }
            ),
               let realSource = createAccountInstruction.parsed?.info.source {
                fromAddress = realSource
            }
            
            // get token from mint address and finish request
            return Single.zip(
                    solanaSDK.getTokenWithMint(mints[0]),
                    solanaSDK.getTokenWithMint(mints[1])
                )
                    .map { fromToken, toToken in
                        let sourceWallet = Wallet(
                                pubkey: fromAddress,
                                lamports: 0, // post token balance?
                                token: fromToken
                        )
                        
                        let destinationWallet = Wallet(
                                pubkey: toAddress,
                                lamports: 0, // post token balances
                                token: toToken
                        )
                        
                        return .init(
                                source: sourceWallet,
                                sourceAmount: fromAmount?.convertToBalance(decimals: fromToken.decimals),
                                destination: destinationWallet,
                                destinationAmount: toAmount?.convertToBalance(decimals: toToken.decimals),
                                myAccountSymbol: myAccountSymbol
                        )
                    }
        }
    }
}

private extension String {
    var isUSDxMint: Bool {
        self == SolanaSDK.PublicKey.usdtMint.base58EncodedString ||
                self == SolanaSDK.PublicKey.usdcMint.base58EncodedString
    }
}

extension SolanaSDK {
    func getAccountInfo(account: String?, retryWithAccount retryAccount: String? = nil) -> Single<AccountInfo?> {
        guard let account = account else {
            return .just(nil)
        }
        return getAccountInfo(
                account: account,
                decodedTo: AccountInfo.self
            )
            .map {
                Optional($0.data)
            }
            .catchAndReturn(nil)
            .flatMap {
                if $0 == nil,
                   let retryAccount = retryAccount {
                    return self.getAccountInfo(account: retryAccount)
                }
                return .just($0)
            }
    }
    
    func getTokenWithMint(_ mint: String?) -> Single<Token> {
        guard let mint = mint else {
            return .just(.unsupported(mint: nil))
        }
        return getTokensList()
            .map {
                $0.first(where: { $0.address == mint }) ?? .unsupported(mint: mint)
            }
    }
}
