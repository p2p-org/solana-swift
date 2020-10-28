//
//  SolanaSDK+Methods.swift
//  SolanaSwift
//
//  Created by Chung Tran on 10/27/20.
//
// NOTE: THIS FILE IS GENERATED FROM APIGEN PACKAGE, DO NOT MAKE CHANGES DIRECTLY INTO IT, PLEASE EDIT METHODS.JSON AND methodsGen.js TO MAKE CHANGES (IN ../APIGen FOLDER)

import Foundation
import RxSwift

public extension SolanaSDK {
	public func getAccountInfo(account: String, configs: RequestConfiguration? = RequestConfiguration(encoding: "base58")) -> Single<AccountInfo?> {
		(request(parameters: [account, configs]) as Single<Rpc<AccountInfo?>>)
			.map {$0.value}
	}
	public func getBalance(account: String, commitment: Commitment? = nil) -> Single<UInt64> {
		(request(parameters: [account, RequestConfiguration(commitment: commitment)]) as Single<Rpc<UInt64>>)
			.map {$0.value}
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
	public func getConfirmedSignaturesForAddress2(account: String, configs: RequestConfiguration? = nil) -> Single<TransactionSignatureInfo> {
		request(parameters: [account, configs])
	}
	public func getConfirmedTransaction(transactionSignature: String, encoding: String = "json") -> Single<TransactionInfo> {
		request(parameters: [transactionSignature, encoding])
	}
	public func getEpochInfo(commitment: Commitment? = nil) -> Single<EpochInfo> {
		request(parameters: [RequestConfiguration(commitment: commitment)])
	}
	public func getEpochSchedule() -> Single<EpochSchedule> {
		request()
	}
	public func getFeeCalculatorForBlockhash(blockhash: String, commitment: Commitment? = nil) -> Single<Fee> {
		(request(parameters: [blockhash, RequestConfiguration(commitment: commitment)]) as Single<Rpc<Fee>>)
			.map {$0.value}
	}
	public func getFeeRateGovernor() -> Single<Fee> {
		(request() as Single<Rpc<Fee>>)
			.map {$0.value}
	}
	public func getFees(commitment: Commitment? = nil) -> Single<[Fee]> {
		(request(parameters: [RequestConfiguration(commitment: commitment)]) as Single<Rpc<[Fee]>>)
			.map {$0.value}
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
		request(parameters: [RequestConfiguration(commitment: commitment)])
	}
	public func getInflationRate() -> Single<InflationRate> {
		request()
	}
	public func getLargestAccounts() -> Single<[LargestAccount]> {
		(request() as Single<Rpc<[LargestAccount]>>)
			.map {$0.value}
	}
	public func getLeaderSchedule(epoch: UInt64? = nil, commitment: Commitment? = nil) -> Single<[String: [Int]]?> {
		request(parameters: [epoch, RequestConfiguration(commitment: commitment)])
	}
	public func getMinimumBalanceForRentExemption(dataLength: UInt64, commitment: Commitment? = nil) -> Single<UInt64> {
		request(parameters: [dataLength, RequestConfiguration(commitment: commitment)])
	}
	public func getMultipleAccounts(pubkeys: [String], configs: RequestConfiguration? = nil) -> Single<[AccountInfo]?> {
		(request(parameters: [pubkeys, configs]) as Single<Rpc<[AccountInfo]?>>)
			.map {$0.value}
	}
	public func getProgramAccounts(programPubkey: String, configs: RequestConfiguration? = nil) -> Single<[ProgramAccount]> {
		request(parameters: [programPubkey, configs])
	}
	public func getRecentBlockhash(commitment: Commitment? = nil) -> Single<Fee> {
		(request(parameters: [RequestConfiguration(commitment: commitment)]) as Single<Rpc<Fee>>)
			.map {$0.value}
	}
	public func getRecentPerformanceSamples(limit: UInt64) -> Single<[PerformanceSample]> {
		request(parameters: [limit])
	}
	public func getSignatureStatuses(pubkeys: [String], configs: RequestConfiguration? = nil) -> Single<[SignatureStatus?]> {
		(request(parameters: [pubkeys, configs]) as Single<Rpc<[SignatureStatus?]>>)
			.map {$0.value}
	}
	public func getSlot(commitment: Commitment? = nil) -> Single<UInt64> {
		request(parameters: [RequestConfiguration(commitment: commitment)])
	}
	public func getSlotLeader(commitment: Commitment? = nil) -> Single<String> {
		request(parameters: [RequestConfiguration(commitment: commitment)])
	}
	public func getStakeActivation(stakeAccount: String, configs: RequestConfiguration? = nil) -> Single<StakeActivation> {
		request(parameters: [stakeAccount, configs])
	}
	public func getSupply(commitment: Commitment? = nil) -> Single<Supply> {
		(request(parameters: [RequestConfiguration(commitment: commitment)]) as Single<Rpc<Supply>>)
			.map {$0.value}
	}
	public func getTransactionCount(commitment: Commitment? = nil) -> Single<UInt64> {
		request(parameters: [RequestConfiguration(commitment: commitment)])
	}
	public func getTokenAccountBalance(pubkey: String, commitment: Commitment? = nil) -> Single<TokenAccountBalance> {
		request(parameters: [pubkey, RequestConfiguration(commitment: commitment)])
	}
	public func getTokenAccountsByDelegate(pubkey: String, mint: String? = nil, programId: String? = nil, configs: RequestConfiguration? = nil) -> Single<[TokenAccount]> {
		(request(parameters: [pubkey, mint, programId, configs]) as Single<Rpc<[TokenAccount]>>)
			.map {$0.value}
	}
	public func getTokenAccountsByOwner(pubkey: String, mint: String? = nil, programId: String? = nil, configs: RequestConfiguration? = nil) -> Single<[TokenAccount]> {
		(request(parameters: [pubkey, mint, programId, configs]) as Single<Rpc<[TokenAccount]>>)
			.map {$0.value}
	}
	public func getTokenLargestAccounts(pubkey: String, commitment: Commitment? = nil) -> Single<[TokenAmount]> {
		(request(parameters: [pubkey, RequestConfiguration(commitment: commitment)]) as Single<Rpc<[TokenAmount]>>)
			.map {$0.value}
	}
	public func getTokenSupply(pubkey: String, commitment: Commitment? = nil) -> Single<TokenAmount> {
		(request(parameters: [pubkey, RequestConfiguration(commitment: commitment)]) as Single<Rpc<TokenAmount>>)
			.map {$0.value}
	}
	public func getVersion() -> Single<Version> {
		request()
	}
	public func getVoteAccounts(commitment: Commitment? = nil) -> Single<VoteAccounts> {
		request(parameters: [RequestConfiguration(commitment: commitment)])
	}
	public func minimumLedgerSlot() -> Single<UInt64> {
		request()
	}
	public func requestAirdrop(account: String, lamports: UInt64, commitment: Commitment? = nil) -> Single<String> {
		request(parameters: [account, lamports, RequestConfiguration(commitment: commitment)])
	}
	public func sendTransaction(transaction: String, configs: RequestConfiguration? = nil) -> Single<String> {
		request(parameters: [transaction, configs])
	}
	public func simulateTransaction(transaction: String, configs: RequestConfiguration? = nil) -> Single<TransactionStatus> {
		(request(parameters: [transaction, configs]) as Single<Rpc<TransactionStatus>>)
			.map {$0.value}
	}
	public func setLogFilter(filter: String) -> Single<String?> {
		request(parameters: [filter])
	}
	public func validatorExit() -> Single<Bool> {
		request()
	}
}