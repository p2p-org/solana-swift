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
    
    public func getBalance(account: String, commitment: SolanaSDK.Commitment?) async throws -> UInt64 {
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
        try await request()
    }
    
    public func getLargestAccounts() async throws -> [SolanaSDK.LargestAccount] {
        (try await request() as SolanaSDK.Rpc<[SolanaSDK.LargestAccount]>)
            .value
    }
    
    public func getLeaderSchedule(epoch: UInt64?, commitment: SolanaSDK.Commitment?) async throws -> [String : [Int]]? {
        try await request(parameters: [epoch, SolanaSDK.RequestConfiguration(commitment: commitment)])
    }
    
    public func getMinimumBalanceForRentExemption(dataLength: UInt64, commitment: SolanaSDK.Commitment?) async throws -> UInt64 {
        try await request(parameters: [dataLength, SolanaSDK.RequestConfiguration(commitment: commitment)])
    }
    
    public func getMultipleAccounts<T>(pubkeys: [String], decodedTo: T.Type, log: Bool) async throws -> [SolanaSDK.BufferInfo<T>]? where T : DecodableBufferLayout {
        let configs = SolanaSDK.RequestConfiguration(encoding: "base64")
        guard !pubkeys.isEmpty else {return []}
        
        return (try await request(parameters: [pubkeys, configs], log: log) as SolanaSDK.Rpc<[SolanaSDK.BufferInfo<T>]?>)
            .value
    }
    
    public func getProgramAccounts<T>(publicKey: String, configs: SolanaSDK.RequestConfiguration?, decodedTo: T.Type, log: Bool) async throws -> SolanaSDK.ProgramAccounts<T> where T : DecodableBufferLayout {
        try await request(parameters: [publicKey, configs], log: log)
    }
    
    public func getRecentBlockhash(commitment: SolanaSDK.Commitment?) async throws -> String {
        let blockhash = (try await request(parameters: [SolanaSDK.RequestConfiguration(commitment: commitment)]) as SolanaSDK.Rpc<SolanaSDK.Fee>)
            .value
            .blockhash
        guard let blockhash = blockhash else {
            throw Error.blockhashNotFound
        }
        return blockhash
    }
    
    public func getRecentPerformanceSamples(limit: UInt64) async throws -> [SolanaSDK.PerformanceSample] {
        try await request(parameters: [limit])
    }
    
    public func getSignatureStatuses(signatures: [String], configs: SolanaSDK.RequestConfiguration?) async throws -> [SolanaSDK.SignatureStatus?] {
        (try await request(parameters: [signatures, configs]) as SolanaSDK.Rpc<[SolanaSDK.SignatureStatus?]>)
            .value
    }
    
    public func getSignatureStatus(signature: String, configs: SolanaSDK.RequestConfiguration?) async throws -> SolanaSDK.SignatureStatus {
        let values = try await getSignatureStatuses(signatures: [signature], configs: configs)
        guard let status = values.compactMap({$0}).first else {throw Error.invalidSignatureStatus}
        return status
    }
    
    public func getSlot(commitment: SolanaSDK.Commitment?) async throws -> UInt64 {
        try await request(parameters: [SolanaSDK.RequestConfiguration(commitment: commitment)])
    }
    
    public func getSlotLeader(commitment: SolanaSDK.Commitment?) async throws -> String {
        try await request(parameters: [SolanaSDK.RequestConfiguration(commitment: commitment)])
    }
    
    public func getStakeActivation(stakeAccount: String, configs: SolanaSDK.RequestConfiguration?) async throws -> SolanaSDK.StakeActivation {
        try await request(parameters: [stakeAccount, configs])
    }
    
    public func getSupply(commitment: SolanaSDK.Commitment?) async throws -> SolanaSDK.Supply {
        (try await request(parameters: [SolanaSDK.RequestConfiguration(commitment: commitment)]) as SolanaSDK.Rpc<SolanaSDK.Supply>)
            .value
    }
    
    public func getTransactionCount(commitment: SolanaSDK.Commitment?) async throws -> UInt64 {
        try await request(parameters: [SolanaSDK.RequestConfiguration(commitment: commitment)])
    }
    
    public func getTokenAccountBalance(pubkey: String, commitment: SolanaSDK.Commitment?) async throws -> SolanaSDK.TokenAccountBalance {
        let value = (try await request(parameters: [pubkey, SolanaSDK.RequestConfiguration(commitment: commitment)]) as SolanaSDK.Rpc<SolanaSDK.TokenAccountBalance>)
            .value
        
        if UInt64(value.amount) == nil {
            throw Error.couldNotRetrieveAccountInfo
        }
        return value
    }
    
    public func getTokenAccountsByDelegate(pubkey: String, mint: String?, programId: String?, configs: SolanaSDK.RequestConfiguration?) async throws -> [SolanaSDK.TokenAccount<SolanaSDK.AccountInfo>] {
        (try await request(parameters: [pubkey, mint, programId, configs]) as SolanaSDK.Rpc<[SolanaSDK.TokenAccount<SolanaSDK.AccountInfo>]>)
            .value
    }
    
    public func getTokenAccountsByOwner(pubkey: String, params: SolanaSDK.OwnerInfoParams?, configs: SolanaSDK.RequestConfiguration?, log: Bool) async throws -> [SolanaSDK.TokenAccount<SolanaSDK.AccountInfo>] {
        (try await request(parameters: [pubkey, params, configs], log: log) as SolanaSDK.Rpc<[SolanaSDK.TokenAccount<SolanaSDK.AccountInfo>]>)
            .value
    }
    
    public func getTokenLargestAccounts(pubkey: String, commitment: SolanaSDK.Commitment?) async throws -> [SolanaSDK.TokenAmount] {
        (try await request(parameters: [pubkey, SolanaSDK.RequestConfiguration(commitment: commitment)]) as SolanaSDK.Rpc<[SolanaSDK.TokenAmount]>)
            .value
    }
    
    public func getTokenSupply(pubkey: String, commitment: SolanaSDK.Commitment?) async throws -> SolanaSDK.TokenAmount {
        (try await request(parameters: [pubkey, SolanaSDK.RequestConfiguration(commitment: commitment)]) as SolanaSDK.Rpc<SolanaSDK.TokenAmount>)
            .value
    }
    
    public func getVersion() async throws -> SolanaSDK.Version {
        try await request()
    }
    
    public func getVoteAccounts(commitment: SolanaSDK.Commitment?) async throws -> SolanaSDK.VoteAccounts {
        try await request(parameters: [SolanaSDK.RequestConfiguration(commitment: commitment)])
    }
    
    public func minimumLedgerSlot() async throws -> UInt64 {
        try await request()
    }
    
    public func requestAirdrop(account: String, lamports: UInt64, commitment: SolanaSDK.Commitment?) async throws -> String {
        try await request(parameters: [account, lamports, SolanaSDK.RequestConfiguration(commitment: commitment)])
    }
    
    public func sendTransaction(serializedTransaction: String, configs: SolanaSDK.RequestConfiguration) async throws -> SolanaSDK.TransactionID {
        do {
            return try await request(parameters: [serializedTransaction, configs])
        } catch {
            // Modify error message
            if let error = error as? Error {
                switch error {
                case .invalidResponse(let response) where response.message != nil:
                    var message = response.message
                    if let readableMessage = response.data?.logs?
                        .first(where: {$0.contains("Error:")})?
                        .components(separatedBy: "Error: ")
                        .last
                    {
                        message = readableMessage
                    } else if let readableMessage = response.message?
                                .components(separatedBy: "Transaction simulation failed: ")
                                .last
                    {
                        message = readableMessage
                    }
                    
                    throw Error.invalidResponse(SolanaSDK.ResponseError(code: response.code, message: message, data: response.data))
                default:
                    break
                }
            }
            throw error
        }
        
    }
    
    public func simulateTransaction(transaction: String, configs: SolanaSDK.RequestConfiguration) async throws -> SolanaSDK.TransactionStatus {
        let status = (try await request(parameters: [transaction, configs]) as SolanaSDK.Rpc<SolanaSDK.TransactionStatus>)
            .value
        if let err = status.err {
            throw Error.transactionError(err, logs: status.logs)
        }
        return status
    }
    
    public func setLogFilter(filter: String) async throws -> String? {
        try await request(parameters: [filter])
    }
    
    public func validatorExit() async throws -> Bool {
        try await request()
    }
    
    public func waitForConfirmation(signature: String) async throws {
        // Due to a bug (https://github.com/solana-labs/solana/issues/15461)
        // the `confirmationStatus` field could be unpopulated.
        // To handle this case, also check the `confirmations` field.
        // Note that a `null` value for `confirmations` signals that the
        // transaction was finalized.
        try await Task.retrying(
            where: {($0 as? Error) == .transactionHasNotBeenConfirmed},
            maxRetryCount: .max,
            retryDelay: 1
        ) { [weak self] in
            guard let self = self else {throw Error.unknown}
            let status = try await self.getSignatureStatus(signature: signature)
//            if let confirmations = status.confirmations,
//               confirmations > 0
//            {
//                partiallyConfirmed = true
//            }
            let finalized = status.confirmations == nil ||
                status.confirmationStatus == "finalized"
            if finalized {return}
            throw Error.transactionHasNotBeenConfirmed
        }
            .value
    }
}
