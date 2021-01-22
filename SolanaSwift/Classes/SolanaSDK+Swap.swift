//
//  SolanaSDK+Swap.swift
//  SolanaSwift
//
//  Created by Chung Tran on 21/01/2021.
//

import Foundation
import RxSwift

extension SolanaSDK {
    public func swap(
        owner: Account,
        fromToken tokenSource: PublicKey,
        toToken tokenDestination: PublicKey,
        slippage: Double,
        amount tokenInputAmount: UInt64,
        network: String
    ) {
        let ownerPubkey = owner.publicKey
        let swapProgramId = PublicKey.swapProgramId
        let poolAddress = PublicKey.poolAddress
        
        var tokenA: PublicKey!
        var tokenB: PublicKey!
        var mintA: PublicKey!
        var mintB: PublicKey!
        var minAmountIn: UInt64!
        
        var signers = [owner]
        
        var pool: Pool!
        
        // get pool info
        getPoolInfo(address: poolAddress.base58EncodedString)
            // get balances
            .flatMap {newPool -> Single<[Any]> in
                // save pool
                pool = newPool
                
                // swap type
                tokenA = pool.swapData.tokenAccountA
                tokenB = pool.swapData.tokenAccountB
                mintA = pool.swapData.mintA
                mintB = pool.swapData.mintB
                //                var isSourceEqToPoolTokenAccountA = true
                if tokenSource != pool.swapData.tokenAccountA {
                    tokenA = pool.swapData.tokenAccountB
                    tokenB = pool.swapData.tokenAccountA
                    mintA = pool.swapData.mintB
                    mintB = pool.swapData.mintA
                    //                    isSourceEqToPoolTokenAccountA = false
                }
                
                return Single.zip(
                    [
                        self.getTokenAccountBalance(pubkey: tokenA.base58EncodedString)
                            .map {$0 as Any},
                        self.getTokenAccountBalance(pubkey: tokenB.base58EncodedString)
                            .map {$0 as Any},
                        self.getAccountInfoData(account: tokenA.base58EncodedString, tokenProgramId: .tokenProgramId)
                            .map {$0 as Any},
                        self.getMinimumBalanceForRentExemption(dataLength: UInt64(_AccountInfoData.BUFFER_LENGTH))
                            .map {$0 as Any}
                    ]
                )
            }
            .map {params -> Transaction in
                // form transaction
                var transaction = Transaction()
                
                // calculate balance
                let tokenABalance = params[0] as! TokenAccountBalance
                let tokenBBalance = params[1] as! TokenAccountBalance
                minAmountIn = self.calculateAmount(tokenABalance: UInt64(tokenABalance.amount)!, tokenBBalance:  UInt64(tokenBBalance.amount)!, slippage: slippage, inputAmount: tokenInputAmount)
                
                // account info
                let tokenAInfo = params[2] as! _AccountInfoData
                let minimumBalanceForRentExemption = params[3] as! UInt64
                
                var fromAccount: PublicKey!
                var toAccount: PublicKey!
                
                if tokenAInfo.isNative {
                    let newAccount = try transaction.createAndInitializeAccount(
                        ownerPubkey: ownerPubkey,
                        tokenInputAmount: tokenInputAmount,
                        minimumBalanceForRentExemption: minimumBalanceForRentExemption,
                        inNetwork: network
                    )
                    
                    signers.append(newAccount)
                    
                    fromAccount = newAccount.publicKey
                } else {
                    fromAccount = self.findAccountAddress(tokenMint: mintA)
                }
                
                toAccount = self.findAccountAddress(tokenMint: mintB)
                let isWrappedSol = mintB == .wrappedSOLMint
                
                if toAccount == nil {
                    let newAccount = try transaction.createAndInitializeAccount(
                        ownerPubkey: ownerPubkey,
                        tokenInputAmount: tokenInputAmount,
                        minimumBalanceForRentExemption: minimumBalanceForRentExemption,
                        inNetwork: network
                    )
                    
                    signers.append(newAccount)
                    
                    toAccount = newAccount.publicKey
                }
                
                // APPROVAL
                let approveInstruction = SPLTokenProgram.approveInstruction(
                    tokenProgramId: .tokenProgramId,
                    account: fromAccount,
                    delegate: pool.authority,
                    owner: ownerPubkey,
                    amount: tokenInputAmount
                )
                
                let swapInstruction = TokenSwapProgram.swapInstruction(
                    tokenSwapAccount: poolAddress,
                    authority: pool.authority,
                    userSource: fromAccount,
                    poolSource: tokenA,
                    poolDestination: tokenB,
                    userDestination: toAccount,
                    poolMint: pool.swapData.tokenPool,
                    feeAccount: pool.swapData.feeAccount,
                    hostFeeAccount: pool.swapData.feeAccount,
                    tokenProgramId: .tokenProgramId,
                    swapProgramId: .swapProgramId,
                    amountIn: tokenInputAmount,
                    minimumAmountOut: minAmountIn
                )
                
                transaction.message.add(instruction: approveInstruction)
                transaction.message.add(instruction: swapInstruction)
                
                return transaction
            }
        
        
        
    }
    
    // MARK: - Helpers
    private func addCreateAccountInstructionToTransaction(
        transaction: inout Transaction,
        signers: inout [Account],
        withTokenInputAmount tokenInputAmount: UInt64,
        balanceNeeded: UInt64,
        ownerPubkey: PublicKey,
        inNetwork network: String
    ) throws -> Account {
        let newAccount = try Account(network: network)
        let newAccountPubkey = newAccount.publicKey
        
        let createAccountInstruction = SPLTokenProgram.createAccountInstruction(from: ownerPubkey, toNewPubkey: newAccountPubkey, lamports: tokenInputAmount + balanceNeeded, space: UInt64(_AccountInfoData.BUFFER_LENGTH), programPubkey: .tokenProgramId)
        
        let initializeAccountInstruction = SPLTokenProgram.initializeAccountInstruction(programId: .tokenProgramId, account: newAccountPubkey, mint: .wrappedSOLMint, owner: ownerPubkey)
        
        transaction.message.add(instruction: createAccountInstruction)
        transaction.message.add(instruction: initializeAccountInstruction)
        
        signers.append(newAccount)
        return newAccount
    }
    
    private func findAccountAddress(tokenMint: PublicKey) -> PublicKey? {
        // TODO: - findAccountAddress
        return try! PublicKey(string: "7PECuw9WYABTpb19mGMwbq7ZDHnXcd1kTqXu1NuCP9o4")
    }

    private func calculateAmount(
        tokenABalance: UInt64,
        tokenBBalance: UInt64,
        slippage: Double,
        inputAmount: UInt64
    ) -> UInt64 {
        let estimatedAmount = tokenBBalance * inputAmount / (tokenABalance + inputAmount)
        return UInt64(Float64(estimatedAmount) * Float64(1 - slippage))
    }
    
    private func getPoolInfo(address: String) -> Single<Pool> {
        getAccountInfo(account: address, decodedTo: TokenSwapInfo.self)
            .map { info -> TokenSwapInfo in
                let swapInfo = info.data.value
                if let swapInfo = swapInfo {
                    return swapInfo
                }
                throw Error.other("Invalid data")
            }
            .flatMap { swapData in
                Single.zip([
                    self.getMintData(mintAddress: swapData.mintA, programId: PublicKey.tokenProgramId),
                    self.getMintData(mintAddress: swapData.mintB, programId: PublicKey.tokenProgramId),
                    self.getMintData(mintAddress: swapData.tokenPool, programId: PublicKey.tokenProgramId)
                ])
                .map { mintDatas in
                    guard let authority = mintDatas[2].mintAuthority else {
                        throw Error.other("Invalid mintAuthority")
                    }
                    return Pool(tokenAInfo: mintDatas[0], tokenBInfo: mintDatas[1], poolTokenMint: mintDatas[2], authority: authority, swapData: swapData)
                }
            }
    }
    
    private func getMintData(
        mintAddress: PublicKey,
        programId: PublicKey
    ) -> Single<Mint> {
        getAccountInfo(account: mintAddress.base58EncodedString, decodedTo: Mint.self)
            .map {
                if $0.owner != programId.base58EncodedString {
                    throw Error.other("Invalid mint owner")
                }
                
                if let data = $0.data.value {
                    return data
                }
                
                throw Error.other("Invalid data")
            }
    }
    
    private func getAccountInfoData(account: String, tokenProgramId: PublicKey) -> Single<_AccountInfoData> {
        getAccountInfo(account: account, decodedTo: _AccountInfoData.self)
            .map {
                if let info = $0.data.value {
                    if info.owner != tokenProgramId {
                        throw Error.other("Invalid account owner")
                    }
                    return info
                }
                throw Error.other("Invalid data")
            }
    }
    
    private struct _AccountInfoData: BufferLayout {
        let mint: PublicKey
        let owner: PublicKey
        let amount: UInt64
        let delegateOption: UInt32
        var delegate: PublicKey?
        let isInitialized: Bool
        let isFrozen: Bool
        let state: UInt8
        let isNativeOption: UInt32
        let rentExemptReserve: UInt64?
        let isNativeRaw: UInt64
        let isNative: Bool
        var delegatedAmount: UInt64
        let closeAuthorityOption: UInt32
        var closeAuthority: PublicKey?
        
        public init?(_ keys: [String : [UInt8]]) {
            guard let mint = try? PublicKey(bytes: keys["mint"]),
                  let owner = try? PublicKey(bytes: keys["owner"]),
                  let amount = keys["amount"]?.toUInt64(),
                  let delegateOption = keys["delegateOption"]?.toUInt32(),
                  let delegate = try? PublicKey(bytes: keys["delegate"]),
                  let state = keys["state"]?.first,
                  let isNativeOption = keys["isNativeOption"]?.toUInt32(),
                  let isNativeRaw = keys["isNativeRaw"]?.toUInt64(),
                  let delegatedAmount = keys["delegatedAmount"]?.toUInt64(),
                  let closeAuthorityOption = keys["closeAuthorityOption"]?.toUInt32(),
                  let closeAuthority = try? PublicKey(bytes: keys["closeAuthority"])
            else {
                return nil
            }
            
            self.mint = mint
            self.owner = owner
            self.amount = amount
            self.delegateOption = delegateOption
            self.delegate = delegate
            self.state = state
            self.isNativeOption = isNativeOption
            self.isNativeRaw = isNativeRaw
            self.delegatedAmount = delegatedAmount
            self.closeAuthorityOption = closeAuthorityOption
            self.closeAuthority = closeAuthority
            
            if delegateOption == 0 {
                self.delegate = nil
                self.delegatedAmount = 0
            }
            
            self.isInitialized = state != 0
            self.isFrozen = state == 2
            
            if isNativeOption == 1 {
                self.rentExemptReserve = isNativeRaw
                self.isNative = true
            } else {
                self.rentExemptReserve = nil
                isNative = false
            }
            
            if closeAuthorityOption == 0 {
                self.closeAuthority = nil
            }
        }
        
        public static func layout() -> [(key: String?, length: Int)] {
            [
                (key: "mint", length: PublicKey.LENGTH),
                (key: "owner", length: PublicKey.LENGTH),
                (key: "amount", length: 8),
                (key: "delegateOption", length: 4),
                (key: "delegate", length: PublicKey.LENGTH),
                (key: "state", length: 1),
                (key: "isNativeOption", length: 4),
                (key: "isNativeRaw", length: 8),
                (key: "delegatedAmount", length: 8),
                (key: "closeAuthorityOption", length: 4),
                (key: "closeAuthority", length: PublicKey.LENGTH),
            ]
        }
    }
}
