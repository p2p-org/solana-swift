//
//  File.swift
//  
//
//  Created by Chung Tran on 14/04/2022.
//

import Foundation

extension SolanaSDK.APIClient: SolanaAPIClientType {
    public func getAccountInfo<T>(account: String, decodedTo: T.Type) async throws -> SolanaSDK.BufferInfo<T> where T : DecodableBufferLayout {
        let configs = SolanaSDK.RequestConfiguration(encoding: "base64")
        let result = try await request(parameters: [account, configs]) as SolanaSDK.Rpc<SolanaSDK.BufferInfo<T>?>
        guard let value = result.value else {
            throw Error.couldNotRetrieveAccountInfo
        }
        return value
    }
    
    public func getBalance(account: String?, commitment: SolanaSDK.Commitment?) async throws -> UInt64 {
        (try await request(parameters: [account, SolanaSDK.RequestConfiguration(commitment: commitment)]) as SolanaSDK.Rpc<UInt64>)
            .value
    }
    
    public func getBlockCommitment(block: String) async throws -> SolanaSDK.BlockCommitment {
        try await request(parameters: [block])
    }
    
    public func getBlockTime(block: UInt64) async throws -> Date? {
        let timestamp = try await request(parameters: [block]) as Int64?
        guard let timestamp = timestamp else {return nil}
        return Date(timeIntervalSince1970: TimeInterval(timestamp))
    }
    
    public func getClusterNodes() async throws -> SolanaSDK.ClusterNodes {
        try await request()
    }
    
    public func getConfirmedBlock(slot: UInt64, encoding: String) async throws -> SolanaSDK.ConfirmedBlock? {
        try await request(parameters: [slot, encoding])
    }
    
    public func getConfirmedBlocks(startSlot: UInt64, endSlot: UInt64) async throws -> [UInt64] {
        try await request(parameters: [startSlot, endSlot])
    }
    
    public func getConfirmedBlocksWithLimit(startSlot: UInt64, limit: UInt64) async throws -> [UInt64] {
        try await request(parameters: [startSlot, limit])
    }
    
    public func getConfirmedSignaturesForAddress(account: String, startSlot: UInt64, endSlot: UInt64) async throws -> [String] {
        try await request(parameters: [account, startSlot, endSlot])
    }
    
    public func getConfirmedSignaturesForAddress2(account: String, configs: SolanaSDK.RequestConfiguration?) async throws -> [SolanaSDK.SignatureInfo] {
        try await request(
            overridingEndpoint: "https://api.mainnet-beta.solana.com",
            parameters: [account, configs]
        )
    }
    
    public func getSignaturesForAddress(address: String, configs: SolanaSDK.RequestConfiguration?) async throws -> [SolanaSDK.SignatureInfo] {
        try await request(
            overridingEndpoint: "https://api.mainnet-beta.solana.com",
            parameters: [address, configs],
            onMethodNotFoundReplaceWith: "getConfirmedSignaturesForAddress2"
        )
    }
    
    public func getConfirmedTransaction(transactionSignature: String) async throws -> SolanaSDK.TransactionInfo {
        try await request(
            overridingEndpoint: "https://api.mainnet-beta.solana.com",
            parameters: [transactionSignature, "jsonParsed"]
        )
    }
    
    public func getTransaction(transactionSignature: String) async throws -> SolanaSDK.TransactionInfo {
        try await request(
            overridingEndpoint: "https://api.mainnet-beta.solana.com",
            parameters: [transactionSignature, "jsonParsed"],
            onMethodNotFoundReplaceWith: "getConfirmedTransaction"
        )
    }
    
    public func getEpochInfo(commitment: SolanaSDK.Commitment?) async throws -> SolanaSDK.EpochInfo {
        try await request(parameters: [SolanaSDK.RequestConfiguration(commitment: commitment)])
    }
    
    public func getEpochSchedule() async throws -> SolanaSDK.EpochSchedule {
        try await request()
    }
    
    public func getFeeCalculatorForBlockhash(blockhash: String, commitment: SolanaSDK.Commitment?) async throws -> SolanaSDK.Fee {
        (try await request(parameters: [blockhash, SolanaSDK.RequestConfiguration(commitment: commitment)]) as SolanaSDK.Rpc<SolanaSDK.Fee>)
            .value
    }
    
    public func getFeeRateGovernor() async throws -> SolanaSDK.Fee {
        (try await request() as SolanaSDK.Rpc<SolanaSDK.Fee>)
            .value
    }
    
    public func getFees(commitment: SolanaSDK.Commitment?) async throws -> SolanaSDK.Fee {
        (try await request(parameters: [SolanaSDK.RequestConfiguration(commitment: commitment)]) as SolanaSDK.Rpc<SolanaSDK.Fee>)
            .value
    }
    
    public func getFirstAvailableBlock() async throws -> UInt64 {
        try await request()
    }
    
    public func getGenesisHash() async throws -> String {
        try await request()
    }
    
    public func getIdentity() async throws -> String {
        try await request()
    }
    
    public func getInflationGovernor(commitment: SolanaSDK.Commitment?) async throws -> SolanaSDK.InflationGovernor {
        try await request(parameters: [SolanaSDK.RequestConfiguration(commitment: commitment)])
    }
    
    public func getInflationRate() async throws -> SolanaSDK.InflationRate {
        <#code#>
    }
    
    public func getLargestAccounts() async throws -> [SolanaSDK.LargestAccount] {
        <#code#>
    }
    
    public func getLeaderSchedule(epoch: UInt64?, commitment: SolanaSDK.Commitment?) async throws -> [String : [Int]]? {
        <#code#>
    }
    
    public func getMinimumBalanceForRentExemption(dataLength: UInt64, commitment: SolanaSDK.Commitment?) async throws -> UInt64 {
        <#code#>
    }
    
    public func getMinimumBalanceForRentExemption(span: UInt64) async throws -> UInt64 {
        <#code#>
    }
    
    public func getMultipleAccounts<T>(pubkeys: [String], decodedTo: T.Type, log: Bool) async throws -> [SolanaSDK.BufferInfo<T>]? where T : DecodableBufferLayout {
        <#code#>
    }
    
    public func getProgramAccounts<T>(publicKey: String, configs: SolanaSDK.RequestConfiguration?, decodedTo: T.Type, log: Bool) async throws -> SolanaSDK.ProgramAccounts<T> where T : DecodableBufferLayout {
        <#code#>
    }
    
    public func getRecentBlockhash(commitment: SolanaSDK.Commitment?) async throws -> String {
        <#code#>
    }
    
    public func getRecentPerformanceSamples(limit: UInt64) async throws -> [SolanaSDK.PerformanceSample] {
        <#code#>
    }
    
    public func getSignatureStatuses(signatures: [String], configs: SolanaSDK.RequestConfiguration?) async throws -> [SolanaSDK.SignatureStatus?] {
        <#code#>
    }
    
    public func getSignatureStatus(signature: String, configs: SolanaSDK.RequestConfiguration?) async throws -> SolanaSDK.SignatureStatus {
        <#code#>
    }
    
    public func getSlot(commitment: SolanaSDK.Commitment?) async throws -> UInt64 {
        <#code#>
    }
    
    public func getSlotLeader(commitment: SolanaSDK.Commitment?) async throws -> String {
        <#code#>
    }
    
    public func getStakeActivation(stakeAccount: String, configs: SolanaSDK.RequestConfiguration?) async throws -> SolanaSDK.StakeActivation {
        <#code#>
    }
    
    public func getSupply(commitment: SolanaSDK.Commitment?) async throws -> SolanaSDK.Supply {
        <#code#>
    }
    
    public func getTransactionCount(commitment: SolanaSDK.Commitment?) async throws -> UInt64 {
        <#code#>
    }
    
    public func getTokenAccountBalance(pubkey: String, commitment: SolanaSDK.Commitment?) async throws -> SolanaSDK.TokenAccountBalance {
        <#code#>
    }
    
    public func getTokenAccountsByDelegate(pubkey: String, mint: String?, programId: String?, configs: SolanaSDK.RequestConfiguration?) async throws -> [SolanaSDK.TokenAccount<SolanaSDK.AccountInfo>] {
        <#code#>
    }
    
    public func getTokenAccountsByOwner(pubkey: String, params: SolanaSDK.OwnerInfoParams?, configs: SolanaSDK.RequestConfiguration?, log: Bool) async throws -> [SolanaSDK.TokenAccount<SolanaSDK.AccountInfo>] {
        <#code#>
    }
    
    public func getTokenLargestAccounts(pubkey: String, commitment: SolanaSDK.Commitment?) async throws -> [SolanaSDK.TokenAmount] {
        <#code#>
    }
    
    public func getTokenSupply(pubkey: String, commitment: SolanaSDK.Commitment?) async throws -> SolanaSDK.TokenAmount {
        <#code#>
    }
    
    public func getVersion() async throws -> SolanaSDK.Version {
        <#code#>
    }
    
    public func getVoteAccounts(commitment: SolanaSDK.Commitment?) async throws -> SolanaSDK.VoteAccounts {
        <#code#>
    }
    
    public func minimumLedgerSlot() async throws -> UInt64 {
        <#code#>
    }
    
    public func requestAirdrop(account: String, lamports: UInt64, commitment: SolanaSDK.Commitment?) async throws -> String {
        <#code#>
    }
    
    public func sendTransaction(serializedTransaction: String, configs: SolanaSDK.RequestConfiguration) async throws -> SolanaSDK.TransactionID {
        <#code#>
    }
    
    public func simulateTransaction(transaction: String, configs: SolanaSDK.RequestConfiguration) async throws -> SolanaSDK.TransactionStatus {
        <#code#>
    }
    
    public func setLogFilter(filter: String) async throws -> String? {
        <#code#>
    }
    
    public func validatorExit() async throws -> Bool {
        <#code#>
    }
    
    public func waitForConfirmation(signature: String) async throws {
        <#code#>
    }
}
