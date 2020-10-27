//
//  SolanaSDK+Methods.swift
//  SolanaSwift
//
//  Created by Chung Tran on 10/27/20.
//
import Foundation

public extension SolanaSDK {
	public func getAccountInfo() -> Single<Rpc<AccountInfo?>> {
		request()
	}
	public func getBalance() -> Single<Rpc<UInt64>> {
		request()
	}
	public func getBlockCommitment(block: String) -> Single<BlockCommitment> {
		request(parameters: [block])
	}
	public func getBlockTime(block: String) -> Single<UInt64?> {
		request(parameters: [block])
	}
	public func getClusterNodes() -> Single<ClusterNodes> {
		request()
	}
	public func getConfirmedBlock(slot: UInt64, encoding: String = "json") -> Single<ConfirmedBlock?> {
		request(parameters: [slot, encoding])
	}
	public func getConfirmedBlocks(startSlot: UInt64, endSlot: UInt64) -> Single<[UInt64]> {
		request(parameters: [startSlot, endSlot])
	}
	public func getConfirmedBlocksWithLimit(startSlot: UInt64, limit: UInt64) -> Single<[UInt64]> {
		request(parameters: [startSlot, limit])
	}
	public func getConfirmedSignaturesForAddress(account: String, startSlot: UInt64, endSlot: UInt64) -> Single<[String]> {
		request(parameters: [account, startSlot, endSlot])
	}
	public func getConfirmedSignaturesForAddress2(account: String, configurations: RequestConfiguration? = nil) -> Single<TransactionSignatureInfo> {
		request(parameters: [account, configurations])
	}
	public func getConfirmedTransaction(transactionSignature: String, encoding: String = "json") -> Single<TransactionInfo> {
		request(parameters: [transactionSignature, encoding])
	}
	public func getEpochInfo(commitment: Commitment? = nil) -> Single<EpochInfo> {
		request(parameters: [commitment])
	}
	public func getEpochSchedule() -> Single<EpochSchedule> {
		request()
	}
	public func getFeeCalculatorForBlockhash(blockhash: String, commitment: Commitment? = nil) -> Single<Rpc<Fee>> {
		request(parameters: [blockhash, commitment])
	}
	public func getFeeRateGovernor() -> Single<Rpc<Fee>> {
		request()
	}
	public func getFees(commitment: Commitment? = nil) -> Single<Rpc<[Fee]>> {
		request(parameters: [commitment])
	}
	public func getFirstAvailableBlock() -> Single<UInt64> {
		request()
	}
	public func getGenesisHash() -> Single<String> {
		request()
	}
	public func getIdentity() -> Single<String> {
		request()
	}
	public func getInflationGovernor(commitment: Commitment? = nil) -> Single<InflationGovernor> {
		request(parameters: [commitment])
	}
	public func getInflationRate() -> Single<InflationRate> {
		request()
	}
	public func getLargestAccounts() -> Single<Rpc<[LargestAccount]>> {
		request()
	}
	public func getLeaderSchedule(epoch: UInt64? = nil, commitment: Commitment? = nil) -> Single<[String: [Int]]?> {
		request(parameters: [epoch, commitment])
	}
	public func getMinimumBalanceForRentExemption(dataLength: UInt64, commitment: Commitment? = nil) -> Single<UInt64> {
		request(parameters: [dataLength, commitment])
	}
	public func getMultipleAccounts(pubkeys: [String], configs: RequestConfiguration? = nil) -> Single<Rpc<[AccountInfo]?>> {
		request(parameters: [pubkeys, configs])
	}
	public func getProgramAccounts(programPubkey: String, configs: RequestConfiguration? = nil) -> Single<[ProgramAccount]> {
		request(parameters: [programPubkey, configs])
	}
	public func getRecentBlockhash(commitment: Commitment? = nil) -> Single<Rpc<Fee>> {
		request(parameters: [commitment])
	}
	public func getRecentPerformanceSamples(limit: UInt64) -> Single<[PerformanceSample]> {
		request(parameters: [limit])
	}
	public func getSignatureStatuses(pubkeys: [String], configs: RequestConfiguration? = nil) -> Single<Rpc<[SignatureStatus?]>> {
		request(parameters: [pubkeys, configs])
	}
	public func getSlot(commitment: Commitment? = nil) -> Single<UInt64> {
		request(parameters: [commitment])
	}
	public func getSlotLeader(commitment: Commitment? = nil) -> Single<String> {
		request(parameters: [commitment])
	}
	public func getStakeActivation(stakeAccount: String, configs: RequestConfiguration? = nil) -> Single<StakeActivation> {
		request(parameters: [stakeAccount, configs])
	}
	public func getSupply(commitment: Commitment? = nil) -> Single<Rpc<Supply>> {
		request(parameters: [commitment])
	}
	public func getTransactionCount(commitment: Commitment? = nil) -> Single<UInt64> {
		request(parameters: [commitment])
	}
	public func getTokenAccountBalance(pubkey: String, commitment: Commitment? = nil) -> Single<TokenAccountBalance> {
		request(parameters: [pubkey, commitment])
	}
	public func getTokenAccountsByDelegate(pubkey: String, mint: String? = nil, programId: String? = nil, configs: RequestConfiguration? = nil) -> Single<Rpc<[TokenAccount]>> {
		request(parameters: [pubkey, mint, programId, configs])
	}
	public func getTokenAccountsByOwner(pubkey: String, mint: String? = nil, programId: String? = nil, configs: RequestConfiguration? = nil) -> Single<Rpc<[TokenAccount]>> {
		request(parameters: [pubkey, mint, programId, configs])
	}
	public func getTokenLargestAccounts(pubkey: String, commitment: Commitment? = nil) -> Single<Rpc<[TokenAmount]>> {
		request(parameters: [pubkey, commitment])
	}
	public func getTokenSupply(pubkey: String, commitment: Commitment? = nil) -> Single<Rpc<TokenAmount>> {
		request(parameters: [pubkey, commitment])
	}
	public func getVersion() -> Single<Version> {
		request()
	}
	public func getVoteAccounts(commitment: Commitment? = nil) -> Single<VoteAccounts> {
		request(parameters: [commitment])
	}
	public func minimumLedgerSlot() -> Single<UInt64> {
		request()
	}
	public func requestAirdrop(account: String, lamports: UInt64, commitment: Commitment? = nil) -> Single<String> {
		request(parameters: [account, lamports, commitment])
	}
	public func sendTransaction(transaction: String, configs: RequestConfiguration? = nil) -> Single<String> {
		request(parameters: [transaction, configs])
	}
	public func simulateTransaction(transaction: String, configs: RequestConfiguration? = nil) -> Single<Rpc<TransactionStatus>> {
		request(parameters: [transaction, configs])
	}
	public func setLogFilter(filter: String) -> Single<String?> {
		request(parameters: [filter])
	}
	public func validatorExit() -> Single<Bool> {
		request()
	}
}