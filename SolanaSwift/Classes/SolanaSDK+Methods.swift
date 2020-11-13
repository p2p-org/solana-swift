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
	func getAccountInfo(account: String, configs: RequestConfiguration? = RequestConfiguration(encoding: "base58")) -> Single<Account.Info?> {
		(request(parameters: [account, configs]) as Single<Rpc<Account.Info?>>)
			.map {$0.value}
	}
	func getBalance(account: String, commitment: Commitment? = nil) -> Single<UInt64> {
		(request(parameters: [account, RequestConfiguration(commitment: commitment)]) as Single<Rpc<UInt64>>)
			.map {$0.value}
	}
	func getBlockCommitment(block: String) -> Single<BlockCommitment> {
		request(parameters: [block])
	}
	func getBlockTime(block: String) -> Single<UInt64?> {
		request(parameters: [block])
	}
	func getClusterNodes() -> Single<ClusterNodes> {
		request()
	}
	func getConfirmedBlock(slot: UInt64, encoding: String = "json") -> Single<ConfirmedBlock?> {
		request(parameters: [slot, encoding])
	}
	func getConfirmedBlocks(startSlot: UInt64, endSlot: UInt64) -> Single<[UInt64]> {
		request(parameters: [startSlot, endSlot])
	}
	func getConfirmedBlocksWithLimit(startSlot: UInt64, limit: UInt64) -> Single<[UInt64]> {
		request(parameters: [startSlot, limit])
	}
	func getConfirmedSignaturesForAddress(account: String, startSlot: UInt64, endSlot: UInt64) -> Single<[String]> {
		request(parameters: [account, startSlot, endSlot])
	}
	func getConfirmedSignaturesForAddress2(account: String, configs: RequestConfiguration? = nil) -> Single<Transaction.SignatureInfo> {
		request(parameters: [account, configs])
	}
	func getConfirmedTransaction(transactionSignature: String, encoding: String = "json") -> Single<Transaction.Info> {
		request(parameters: [transactionSignature, encoding])
	}
	func getEpochInfo(commitment: Commitment? = nil) -> Single<EpochInfo> {
		request(parameters: [RequestConfiguration(commitment: commitment)])
	}
	func getEpochSchedule() -> Single<EpochSchedule> {
		request()
	}
	func getFeeCalculatorForBlockhash(blockhash: String, commitment: Commitment? = nil) -> Single<Fee> {
		(request(parameters: [blockhash, RequestConfiguration(commitment: commitment)]) as Single<Rpc<Fee>>)
			.map {$0.value}
	}
	func getFeeRateGovernor() -> Single<Fee> {
		(request() as Single<Rpc<Fee>>)
			.map {$0.value}
	}
	func getFees(commitment: Commitment? = nil) -> Single<[Fee]> {
		(request(parameters: [RequestConfiguration(commitment: commitment)]) as Single<Rpc<[Fee]>>)
			.map {$0.value}
	}
	func getFirstAvailableBlock() -> Single<UInt64> {
		request()
	}
	func getGenesisHash() -> Single<String> {
		request()
	}
	func getIdentity() -> Single<String> {
		request()
	}
	func getInflationGovernor(commitment: Commitment? = nil) -> Single<InflationGovernor> {
		request(parameters: [RequestConfiguration(commitment: commitment)])
	}
	func getInflationRate() -> Single<InflationRate> {
		request()
	}
	func getLargestAccounts() -> Single<[LargestAccount]> {
		(request() as Single<Rpc<[LargestAccount]>>)
			.map {$0.value}
	}
	func getLeaderSchedule(epoch: UInt64? = nil, commitment: Commitment? = nil) -> Single<[String: [Int]]?> {
		request(parameters: [epoch, RequestConfiguration(commitment: commitment)])
	}
	func getMinimumBalanceForRentExemption(dataLength: UInt64, commitment: Commitment? = nil) -> Single<UInt64> {
		request(parameters: [dataLength, RequestConfiguration(commitment: commitment)])
	}
	func getMultipleAccounts(pubkeys: [String], configs: RequestConfiguration? = nil) -> Single<[Account.Info]?> {
		(request(parameters: [pubkeys, configs]) as Single<Rpc<[Account.Info]?>>)
			.map {$0.value}
	}
    func getProgramAccounts(programPubkey: String = "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA", account: String? = nil, in cluster: String) -> Single<[Token]> {
        guard let account = account ?? accountStorage.account?.publicKey.base58EncodedString else {
            return .error(Error.accountNotFound)
        }
        let memcmp = EncodableWrapper(
            wrapped:
                ["offset": EncodableWrapper(wrapped: 32),
                 "bytes": EncodableWrapper(wrapped: account)]
        )
        let configs = RequestConfiguration(commitment: "recent", encoding: "base64", dataSlice: nil, filters: [
            ["memcmp": memcmp],
            ["dataSize": .init(wrapped: 165)]
        ])
		return (request(parameters: [programPubkey, configs]) as Single<[ProgramAccount]>)
            .map {try $0.compactMap {try Token(accountInfo: $0.account, inCluster: cluster)}}
	}
	func getRecentBlockhash(commitment: Commitment? = nil) -> Single<Fee> {
		(request(parameters: [RequestConfiguration(commitment: commitment)]) as Single<Rpc<Fee>>)
			.map {$0.value}
	}
	func getRecentPerformanceSamples(limit: UInt64) -> Single<[PerformanceSample]> {
		request(parameters: [limit])
	}
	func getSignatureStatuses(pubkeys: [String], configs: RequestConfiguration? = nil) -> Single<[SignatureStatus?]> {
		(request(parameters: [pubkeys, configs]) as Single<Rpc<[SignatureStatus?]>>)
			.map {$0.value}
	}
	func getSlot(commitment: Commitment? = nil) -> Single<UInt64> {
		request(parameters: [RequestConfiguration(commitment: commitment)])
	}
	func getSlotLeader(commitment: Commitment? = nil) -> Single<String> {
		request(parameters: [RequestConfiguration(commitment: commitment)])
	}
	func getStakeActivation(stakeAccount: String, configs: RequestConfiguration? = nil) -> Single<StakeActivation> {
		request(parameters: [stakeAccount, configs])
	}
	func getSupply(commitment: Commitment? = nil) -> Single<Supply> {
		(request(parameters: [RequestConfiguration(commitment: commitment)]) as Single<Rpc<Supply>>)
			.map {$0.value}
	}
	func getTransactionCount(commitment: Commitment? = nil) -> Single<UInt64> {
		request(parameters: [RequestConfiguration(commitment: commitment)])
	}
	func getTokenAccountBalance(pubkey: String, commitment: Commitment? = nil) -> Single<TokenAccountBalance> {
		request(parameters: [pubkey, RequestConfiguration(commitment: commitment)])
	}
	func getTokenAccountsByDelegate(pubkey: String, mint: String? = nil, programId: String? = nil, configs: RequestConfiguration? = nil) -> Single<[TokenAccount]> {
		(request(parameters: [pubkey, mint, programId, configs]) as Single<Rpc<[TokenAccount]>>)
			.map {$0.value}
	}
	func getTokenAccountsByOwner(pubkey: String, mint: String? = nil, programId: String? = nil, configs: RequestConfiguration? = nil) -> Single<[TokenAccount]> {
		(request(parameters: [pubkey, mint, programId, configs]) as Single<Rpc<[TokenAccount]>>)
			.map {$0.value}
	}
	func getTokenLargestAccounts(pubkey: String, commitment: Commitment? = nil) -> Single<[TokenAmount]> {
		(request(parameters: [pubkey, RequestConfiguration(commitment: commitment)]) as Single<Rpc<[TokenAmount]>>)
			.map {$0.value}
	}
	func getTokenSupply(pubkey: String, commitment: Commitment? = nil) -> Single<TokenAmount> {
		(request(parameters: [pubkey, RequestConfiguration(commitment: commitment)]) as Single<Rpc<TokenAmount>>)
			.map {$0.value}
	}
	func getVersion() -> Single<Version> {
		request()
	}
	func getVoteAccounts(commitment: Commitment? = nil) -> Single<VoteAccounts> {
		request(parameters: [RequestConfiguration(commitment: commitment)])
	}
	func minimumLedgerSlot() -> Single<UInt64> {
		request()
	}
	func requestAirdrop(account: String, lamports: UInt64, commitment: Commitment? = nil) -> Single<String> {
		request(parameters: [account, lamports, RequestConfiguration(commitment: commitment)])
	}
	internal func sendTransaction(serializedTransaction: String, configs: RequestConfiguration = RequestConfiguration(encoding: "base64")!) -> Single<String> {
		request(parameters: [serializedTransaction, configs])
	}
	func simulateTransaction(transaction: String, configs: RequestConfiguration? = nil) -> Single<Transaction.Status> {
		(request(parameters: [transaction, configs]) as Single<Rpc<Transaction.Status>>)
			.map {$0.value}
	}
	func setLogFilter(filter: String) -> Single<String?> {
		request(parameters: [filter])
	}
	func validatorExit() -> Single<Bool> {
		request()
	}
}
