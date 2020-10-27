//
//  SolanaSDK+Response.swift
//  SolanaSwift
//
//  Created by Chung Tran on 10/27/20.
//
// NOTE: THIS FILE IS GENERATED FROM APIGEN PACKAGE, DO NOT MAKE CHANGES DIRECTLY INTO IT, PLEASE EDIT MODELS.JSON AND modelsGen.js TO MAKE CHANGES (IN ../APIGen FOLDER)

import Foundation
import RxSwift

public extension SolanaSDK {
	public struct Rpc<T: Decodable>: Decodable {
		public let jsonrpc: String
		public let id: String
		public let result: T
	}
	public struct AccountInfo: Decodable {
		public let lamports: UInt64
		public let owners: String
		public let data: [String]
		public let executable: Bool
		public let rentEpoch: UInt64
	}
	public struct BlockCommitment: Decodable {
		public let commitment: [UInt64]?
		public let totalStake: UInt64
	}
	public struct ClusterNodes: Decodable {
		public let pubkey: String
		public let gossip: String
		public let tpu: String
		public let rpc: String?
		public let version: String?
	}
	public struct ConfirmedBlock: Decodable {
		public let blockhash: String
		public let previousBlockhash: String
		public let parentSlot: UInt64
		public let transactions: [TransactionInfo]
		public let rewards: [Reward]
		public let blockTime: UInt64?
	}
	public struct Reward: Decodable {
	}
	public struct TransactionInfo: Decodable {
		public let meta: TransactionMeta?
		public let transaction: Transaction
		public let slot: UInt64?
	}
	public struct TransactionMeta: Decodable {
		public let err: TransactionError?
		public let fee: UInt64
		public let preBalances: [UInt64]
		public let postBalances: [UInt64]
	}
	public struct Transaction: Decodable {
		public let signatures: [String]
		public let message: TransactionMessage
	}
	public struct TransactionError: Decodable {
	}
	public struct TransactionMessage: Decodable {
		public let accountKeys: [String]
		public let header: TransactionMessageHeader
	}
	public struct TransactionSignatureInfo: Decodable {
		public let signature: String
		public let slot: UInt64
		public let err: TransactionError?
		public let memo: String?
	}
	public struct EpochInfo: Decodable {
		public let absoluteSlot: UInt64
		public let blockHeight: UInt64
		public let epoch: UInt64
		public let slotIndex: UInt64
		public let slotsInEpoch: UInt64
	}
	public struct EpochSchedule: Decodable {
		public let slotsPerEpoch: UInt64
		public let leaderScheduleSlotOffset: UInt64
		public let warmup: Bool
		public let firstNormalEpoch: UInt64
		public let firstNormalSlot: UInt64
	}
	public struct Fee: Decodable {
		public let feeCalculator: FeeCalculator?
		public let feeRateGovernor: FeeRateGovernor?
		public let blockhash: String?
		public let lastValidSlot: UInt64
	}
	public struct FeeCalculator: Decodable {
		public let lamportsPerSignature: UInt64
	}
	public struct FeeRateGovernor: Decodable {
		public let burnPercent: UInt64
		public let maxLamportsPerSignature: UInt64
		public let minLamportsPerSignature: UInt64
		public let targetLamportsPerSignature: UInt64
		public let targetSignaturesPerSlot: UInt64
	}
	public struct Identity: Decodable {
		public let identity: String
	}
	public struct InflationGovernor: Decodable {
		public let foundation: Float64
		public let foundationTerm: Float64
		public let initial: Float64
		public let taper: Float64
		public let terminal: Float64
	}
	public struct InflationRate: Decodable {
		public let epoch: Float64
		public let foundation: Float64
		public let total: Float64
		public let validator: Float64
	}
	public struct LargestAccount: Decodable {
		public let lamports: UInt64
		public let address: String
	}
	public struct RequestConfiguration: Decodable {
		public let commitment: Commitment?
	}
	public struct ProgramAccount: Decodable {
		public let account: AccountInfo
		public let pubkey: String
	}
	public struct PerformanceSample: Decodable {
		public let numSlots: UInt64
		public let numTransactions: UInt64
		public let samplePeriodSecs: UInt
		public let slot: UInt64
	}
	public struct SignatureStatus: Decodable {
		public let slot: UInt64
		public let confirmations: UInt64?
		public let err: TransactionError?
	}
	public struct StakeActivation: Decodable {
		public let active: UInt64
		public let inactive: UInt64
		public let state: String
	}
	public struct Supply: Decodable {
		public let circulating: UInt64
		public let nonCirculating: UInt64
		public let nonCirculatingAccounts: [String]
		public let total: UInt64
	}
	public struct TokenAccountBalance: Decodable {
		public let uiAmount: Float64
		public let amount: String
		public let decimals: UInt8
	}
	public struct TokenAccount: Decodable {
		public let pubkey: String
		public let account: AccountInfo
	}
	public struct TokenAmount: Decodable {
		public let address: String?
		public let amount: String
		public let decimals: UInt8
		public let uiAmount: Float64
	}
	public struct Version: Decodable {
		public let solana-core: String
	}
	public struct VoteAccounts: Decodable {
		public let current: [VoteAccount]
		public let delinquent: [VoteAccount]
	}
	public struct VoteAccount: Decodable {
		public let commission: Int
		public let epochVoteAccount: Bool
		public let epochCredits: [[UInt64]]
		public let nodePubkey: String
		public let lastVote: UInt64
		public let activatedStake: UInt64
		public let votePubkey: String
	}
	public struct TransactionStatus: Decodable {
		public let err: TransactionError?
		public let logs: [String]
	}
}
