//
//  File.swift
//  
//
//  Created by Chung Tran on 13/04/2022.
//

import Foundation

public enum RequestType {
    case getAccountInfo<T: DecodableBufferLayout>(account: String, decodedTo: Decodable.Type)
    case getBalance(account: String, commitment: SolanaSDK.Commitment?)
    case getBlockCommitment(block: String)
    case getBlockTime(block: UInt64)
    case getClusterNodes
    case getConfirmedBlock(slot: UInt64, encoding: String)
    case getConfirmedBlocks(startSlot: UInt64, endSlot: UInt64)
    case getConfirmedBlocksWithLimit(startSlot: UInt64, limit: UInt64)
    case getConfirmedSignaturesForAddress(account: String, startSlot: UInt64, endSlot: UInt64)
    @available(*, deprecated, renamed: "getSignaturesForAddress(address:configs:)", message: "use getSignaturesForAddress instead.This method is expected to be removed in solana-core v1.8.")
    case getConfirmedSignaturesForAddress2(account: String, configs: SolanaSDK.RequestConfiguration?)
    case getSignaturesForAddress(address: String, configs: SolanaSDK.RequestConfiguration?)
    @available(*, deprecated, renamed: "getTransaction(transactionSignature:)", message: "use getTransaction instead This method is expected to be removed in solana-core v1.8.")
    case getConfirmedTransaction(transactionSignature: String)
    case getTransaction(transactionSignature: String)
    case getEpochInfo(commitment: SolanaSDK.Commitment?)
    case getEpochSchedule
    case getFeeCalculatorForBlockhash(blockhash: String, commitment: SolanaSDK.Commitment?)
    case getFeeRateGovernor
    case getFees(commitment: SolanaSDK.Commitment?)
    case getFirstAvailableBlock
    case getGenesisHash
    case getIdentity
    case getInflationGovernor(commitment: SolanaSDK.Commitment?)
    case getInflationRate
    case getLargestAccounts
    case getLeaderSchedule(epoch: UInt64?, commitment: SolanaSDK.Commitment?)
    case getMinimumBalanceForRentExemption(dataLength: UInt64, commitment: SolanaSDK.Commitment?)
    case getMultipleAccounts<T: DecodableBufferLayout>(pubkeys: [String], decodedTo: T.Type, log: Bool)
    case getProgramAccounts<T: DecodableBufferLayout>(publicKey: String, configs: SolanaSDK.RequestConfiguration?, decodedTo: T.Type, log: Bool)
    case getRecentBlockhash(commitment: SolanaSDK.Commitment?)
    case getRecentPerformanceSamples(limit: UInt64)
    case getSignatureStatuses(signatures: [String], configs: SolanaSDK.RequestConfiguration?)
    case getSignatureStatus(signature: String, configs: SolanaSDK.RequestConfiguration?)
    case getSlot(commitment: SolanaSDK.Commitment?)
    case getSlotLeader(commitment: SolanaSDK.Commitment?)
    case getStakeActivation(stakeAccount: String, configs: SolanaSDK.RequestConfiguration?)
    case getSupply(commitment: SolanaSDK.Commitment?)
    case getTransactionCount(commitment: SolanaSDK.Commitment?)
    case getTokenAccountBalance(pubkey: String, commitment: SolanaSDK.Commitment?)
    case getTokenAccountsByDelegate(pubkey: String, mint: String?, programId: String?, configs: SolanaSDK.RequestConfiguration?)
    case getTokenAccountsByOwner(pubkey: String, params: SolanaSDK.OwnerInfoParams?, configs: SolanaSDK.RequestConfiguration?, log: Bool)
    case getTokenLargestAccounts(pubkey: String, commitment: SolanaSDK.Commitment?)
    case getTokenSupply(pubkey: String, commitment: SolanaSDK.Commitment?)
    case getVersion
    case getVoteAccounts(commitment: SolanaSDK.Commitment?)
    case minimumLedgerSlot
    case requestAirdrop(account: String, lamports: UInt64, commitment: SolanaSDK.Commitment?)
    case sendTransaction(serializedTransaction: String, configs: SolanaSDK.RequestConfiguration)
    case simulateTransaction(transaction: String, configs: SolanaSDK.RequestConfiguration)
    case setLogFilter(filter: String)
    case validatorExit
    case waitForConfirmation(signature: String)
    
    var responseType: Decodable.Type {
        return UInt64.self
    }
}

public protocol SolanaAPIClientType: AnyObject {
    associatedtype HTTPMethod
    associatedtype Error: Swift.Error
    
    func changeEndpoint(to: SolanaSDK.APIEndPoint) async
    
    func getAccountInfo<T: DecodableBufferLayout>(account: String, decodedTo: T.Type) async throws -> SolanaSDK.BufferInfo<T>
    
    func getBalance(account: String, commitment: SolanaSDK.Commitment?) async throws -> UInt64
    
    func getBlockCommitment(block: String) async throws -> SolanaSDK.BlockCommitment
    
    func getBlockTime(block: UInt64) async throws -> Date?
    
    func getClusterNodes() async throws -> [SolanaSDK.ClusterNode]
    
    func getConfirmedBlock(slot: UInt64, encoding: String) async throws -> SolanaSDK.ConfirmedBlock?
    
    func getConfirmedBlocks(startSlot: UInt64, endSlot: UInt64) async throws -> [UInt64]
    
    func getConfirmedBlocksWithLimit(startSlot: UInt64, limit: UInt64) async throws -> [UInt64]
    
    func getConfirmedSignaturesForAddress(account: String, startSlot: UInt64, endSlot: UInt64) async throws -> [String]
    
    @available(*, deprecated, renamed: "getSignaturesForAddress(address:configs:)", message: "use getSignaturesForAddress instead.This method is expected to be removed in solana-core v1.8.")
    func getConfirmedSignaturesForAddress2(account: String, configs: SolanaSDK.RequestConfiguration?) async throws -> [SolanaSDK.SignatureInfo]
    
    func getSignaturesForAddress(address: String, configs: SolanaSDK.RequestConfiguration?) async throws -> [SolanaSDK.SignatureInfo]
    
    @available(*, deprecated, renamed: "getTransaction(transactionSignature:)", message: "use getTransaction instead This method is expected to be removed in solana-core v1.8.")
    func getConfirmedTransaction(transactionSignature: String) async throws -> SolanaSDK.TransactionInfo
    
    func getTransaction(transactionSignature: String) async throws -> SolanaSDK.TransactionInfo
    
    func getEpochInfo(commitment: SolanaSDK.Commitment?) async throws -> SolanaSDK.EpochInfo
    func getEpochSchedule() async throws -> SolanaSDK.EpochSchedule
    
    func getFeeCalculatorForBlockhash(blockhash: String, commitment: SolanaSDK.Commitment?) async throws -> SolanaSDK.Fee
    
    func getFeeRateGovernor() async throws -> SolanaSDK.Fee
    
    func getFees(commitment: SolanaSDK.Commitment?) async throws -> SolanaSDK.Fee
    
    func getFirstAvailableBlock() async throws -> UInt64
    
    func getGenesisHash() async throws -> String
    
    func getIdentity() async throws -> String
    
    func getInflationGovernor(commitment: SolanaSDK.Commitment?) async throws -> SolanaSDK.InflationGovernor
    
    func getInflationRate() async throws -> SolanaSDK.InflationRate
    
    func getLargestAccounts() async throws -> [SolanaSDK.LargestAccount]
    
    func getLeaderSchedule(epoch: UInt64?, commitment: SolanaSDK.Commitment?) async throws -> [String: [Int]]?
    
    func getMinimumBalanceForRentExemption(dataLength: UInt64, commitment: SolanaSDK.Commitment?) async throws -> UInt64
    
    func getMultipleAccounts<T: DecodableBufferLayout>(pubkeys: [String], decodedTo: T.Type, log: Bool) async throws -> [SolanaSDK.BufferInfo<T>]?
    
    func getProgramAccounts<T: DecodableBufferLayout>(publicKey: String, configs: SolanaSDK.RequestConfiguration?, decodedTo: T.Type, log: Bool) async throws -> SolanaSDK.ProgramAccounts<T>
    
    func getRecentBlockhash(commitment: SolanaSDK.Commitment?) async throws -> String
    
    func getRecentPerformanceSamples(limit: UInt64) async throws -> [SolanaSDK.PerformanceSample]
    
    func getSignatureStatuses(signatures: [String], configs: SolanaSDK.RequestConfiguration?) async throws -> [SolanaSDK.SignatureStatus?]
    
    func getSignatureStatus(signature: String, configs: SolanaSDK.RequestConfiguration?) async throws -> SolanaSDK.SignatureStatus
    
    func getSlot(commitment: SolanaSDK.Commitment?) async throws -> UInt64
    
    func getSlotLeader(commitment: SolanaSDK.Commitment?) async throws -> String
    
    func getStakeActivation(stakeAccount: String, configs: SolanaSDK.RequestConfiguration?) async throws -> SolanaSDK.StakeActivation
    
    func getSupply(commitment: SolanaSDK.Commitment?) async throws -> SolanaSDK.Supply
    
    func getTransactionCount(commitment: SolanaSDK.Commitment?) async throws -> UInt64
    
    func getTokenAccountBalance(pubkey: String, commitment: SolanaSDK.Commitment?) async throws -> SolanaSDK.TokenAccountBalance
    
    func getTokenAccountsByDelegate(pubkey: String, mint: String?, programId: String?, configs: SolanaSDK.RequestConfiguration?) async throws -> [SolanaSDK.TokenAccount<SolanaSDK.AccountInfo>]
    
    func getTokenAccountsByOwner(pubkey: String, params: SolanaSDK.OwnerInfoParams?, configs: SolanaSDK.RequestConfiguration?, log: Bool) async throws -> [SolanaSDK.TokenAccount<SolanaSDK.AccountInfo>]
    
    func getTokenLargestAccounts(pubkey: String, commitment: SolanaSDK.Commitment?) async throws -> [SolanaSDK.TokenAmount]
    
    func getTokenSupply(pubkey: String, commitment: SolanaSDK.Commitment?) async throws -> SolanaSDK.TokenAmount
    
    func getVersion() async throws -> SolanaSDK.Version
    
    func getVoteAccounts(commitment: SolanaSDK.Commitment?) async throws -> SolanaSDK.VoteAccounts
    
    func minimumLedgerSlot() async throws -> UInt64
    
    func requestAirdrop(account: String, lamports: UInt64, commitment: SolanaSDK.Commitment?) async throws -> String
    
    func sendTransaction(serializedTransaction: String, configs: SolanaSDK.RequestConfiguration) async throws -> SolanaSDK.TransactionID
    
    func simulateTransaction(transaction: String, configs: SolanaSDK.RequestConfiguration) async throws -> SolanaSDK.TransactionStatus
    
    func setLogFilter(filter: String) async throws -> String?
    
    func validatorExit() async throws -> Bool
    
    func waitForConfirmation(signature: String) async throws
}

public extension SolanaAPIClientType {
    func getBalance(account: String) async throws -> UInt64 {
        try await getBalance(account: account, commitment: nil)
    }
    @available(*, deprecated, renamed: "getSignaturesForAddress(address:configs:)", message: "use getSignaturesForAddress instead.This method is expected to be removed in solana-core v1.8.")
    func getConfirmedSignaturesForAddress2(account: String) async throws -> [SolanaSDK.SignatureInfo] {
        try await getConfirmedSignaturesForAddress2(account: account, configs: nil)
    }
    func getEpochInfo() async throws -> SolanaSDK.EpochInfo {
        try await getEpochInfo(commitment: nil)
    }
    func getFeeCalculatorForBlockhash(blockhash: String) async throws -> SolanaSDK.Fee {
        try await getFeeCalculatorForBlockhash(blockhash: blockhash, commitment: nil)
    }
    func getInflationGovernor() async throws -> SolanaSDK.InflationGovernor {
        try await getInflationGovernor(commitment: nil)
    }
    func getMinimumBalanceForRentExemption(dataLength: UInt64) async throws -> UInt64 {
        try await getMinimumBalanceForRentExemption(dataLength: dataLength, commitment: "recent")
    }
    func getMinimumBalanceForRentExemption(span: UInt64) async throws -> UInt64 {
        try await getMinimumBalanceForRentExemption(dataLength: span)
    }
    func getMultipleAccounts<T>(pubkeys: [String], decodedTo: T.Type) async throws -> [SolanaSDK.BufferInfo<T>]? where T : DecodableBufferLayout {
        try await getMultipleAccounts(pubkeys: pubkeys, decodedTo: decodedTo, log: true)
    }
    func getProgramAccounts<T>(publicKey: String, decodedTo: T.Type) async throws -> SolanaSDK.ProgramAccounts<T> where T : DecodableBufferLayout {
        try await getProgramAccounts(publicKey: publicKey, configs: .init(encoding: "base64"), decodedTo: decodedTo, log: true)
    }
    func getRecentBlockhash() async throws -> String {
        try await getRecentBlockhash(commitment: nil)
    }
    func getTransactionCount() async throws -> UInt64  {
        try await getTransactionCount(commitment: nil)
    }
    func getSignatureStatus(signature: String) async throws -> SolanaSDK.SignatureStatus {
        try await getSignatureStatus(signature: signature, configs: nil)
    }
}
