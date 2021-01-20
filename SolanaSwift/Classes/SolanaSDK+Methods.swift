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
	func getAccountInfo(account: String) -> Single<MintLayout?> {
        let configs = RequestConfiguration(encoding: "base64")
		return (request(parameters: [account, configs]) as Single<Rpc<AccountInfo<MintLayout>?>>)
            .map {$0.value?.data.value}
	}
	func getBalance(account: String, commitment: Commitment? = nil) -> Single<UInt64> {
		(request(parameters: [account, RequestConfiguration(commitment: commitment)]) as Single<Rpc<UInt64>>)
			.map {$0.value}
	}
	func getBlockCommitment(block: String) -> Single<BlockCommitment> {
		request(parameters: [block])
	}
	func getBlockTime(block: UInt64) -> Single<Date?> {
		(request(parameters: [block]) as Single<Int64?>)
            .map {timestamp in
                guard let timestamp = timestamp else {return nil}
                return Date(timeIntervalSince1970: TimeInterval(timestamp))
            }
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
	func getConfirmedSignaturesForAddress2(account: String, configs: RequestConfiguration? = nil) -> Single<[Transaction.SignatureInfo]> {
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
	func getFees(commitment: Commitment? = nil) -> Single<Fee> {
		(request(parameters: [RequestConfiguration(commitment: commitment)]) as Single<Rpc<Fee>>)
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
    internal func getMinimumBalanceForRentExemption(dataLength: UInt64, commitment: Commitment? = "recent") -> Single<UInt64> {
		request(parameters: [dataLength, RequestConfiguration(commitment: commitment)])
	}
	func getMultipleAccounts(pubkeys: [String], configs: RequestConfiguration? = nil) -> Single<[AccountInfo<AccountLayout>]?> {
		(request(parameters: [pubkeys, configs]) as Single<Rpc<[AccountInfo<AccountLayout>]?>>)
			.map {$0.value}
	}
    func getProgramAccounts(account: String? = nil, shouldParseJSON: Bool = true, in network: String) -> Single<[Token]> {
        guard let account = account ?? accountStorage.account?.publicKey.base58EncodedString else {
            return .error(Error.accountNotFound)
        }
        let memcmp = EncodableWrapper(
            wrapped:
                ["offset": EncodableWrapper(wrapped: 32),
                 "bytes": EncodableWrapper(wrapped: account)]
        )
        let configs = RequestConfiguration(commitment: "recent", encoding: shouldParseJSON ? "jsonParsed": "base64", dataSlice: nil, filters: [
            ["memcmp": memcmp],
            ["dataSize": .init(wrapped: 165)]
        ])
        return (request(parameters: [PublicKey.tokenProgramId.base58EncodedString, configs]) as Single<[ProgramAccount<AccountLayout>]>)
            .map {
                $0.compactMap {
                    $0.account.data.value != nil ?
                        Token(layout: $0.account.data.value!, pubkey: $0.pubkey, in: network)
                        : nil
                }
            }
            .flatMap { tokens in
                var unfilledTokens = [Token]()
                
                // retrieve decimals if missing
                for token in tokens where token.decimals == nil {
                    unfilledTokens.append(token)
                }
                if unfilledTokens.count > 0 {
                    return Single<UInt8>.zip(
                        unfilledTokens.map {
                            return self.getAccountInfo(account: $0.mintAddress)
                                .map {$0?.decimals ?? 0}
                        }
                    )
                    .map {
                        var tokens = tokens
                        for i in 0..<unfilledTokens.count {
                            unfilledTokens[i].decimals = Int($0[i])
                            if let index = tokens.firstIndex(where: {$0.pubkey == unfilledTokens[i].pubkey})
                            {
                                tokens[index] = unfilledTokens[i]
                            }
                        }
                        return tokens
                    }
                }
                
                // if all decimals isn't missing
                return .just(tokens)
            }
	}
	func getRecentBlockhash(commitment: Commitment? = nil) -> Single<String> {
		(request(parameters: [RequestConfiguration(commitment: commitment)]) as Single<Rpc<Fee>>)
			.map {$0.value}
            .map {$0.blockhash}
            .map { recentBlockhash in
                if recentBlockhash == nil {
                    throw Error.other("Could not retrieve recent blockhash")
                }
                return recentBlockhash!
            }
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
    func getTokenAccountsByDelegate(pubkey: String, mint: String? = nil, programId: String? = nil, configs: RequestConfiguration? = nil) -> Single<[TokenAccount<AccountLayout>]> {
		(request(parameters: [pubkey, mint, programId, configs]) as Single<Rpc<[TokenAccount<AccountLayout>]>>)
			.map {$0.value}
	}
    func getTokenAccountsByOwner(pubkey: String, mint: String? = nil, programId: String? = nil, configs: RequestConfiguration? = nil) -> Single<[TokenAccount<AccountLayout>]> {
		(request(parameters: [pubkey, mint, programId, configs]) as Single<Rpc<[TokenAccount<AccountLayout>]>>)
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
