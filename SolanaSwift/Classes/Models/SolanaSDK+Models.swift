//
//  SolanaSDK+Response.swift
//  SolanaSwift
//
//  Created by Chung Tran on 10/27/20.

import Foundation
import RxSwift

public extension SolanaSDK {
    typealias TransactionID = String
    typealias Lamports = UInt64
    typealias Decimals = UInt8
    
	struct Response<T: Decodable>: Decodable {
		public let jsonrpc: String
		public let id: String?
		public let result: T?
		public let error: ResponseError?
        public let method: String?
        
        // socket
        public let params: SocketParams<T>?
	}
    struct SocketParams<T: Decodable>: Decodable {
        public let result: T?
        public let subscription: UInt64?
    }
	struct ResponseError: Decodable {
		public let code: Int?
		public let message: String?
        public let data: ResponseErrorData?
	}
    struct ResponseErrorData: Decodable {
        // public let err: ResponseErrorDataError
        public let logs: [String]
    }
	struct Rpc<T: Decodable>: Decodable {
		public let context: Context
		public let value: T
	}
	struct Context: Decodable {
		public let slot: UInt64
	}
	struct BlockCommitment: Decodable {
		public let commitment: [UInt64]?
		public let totalStake: UInt64
	}
	struct ClusterNodes: Decodable {
		public let pubkey: String
		public let gossip: String
		public let tpu: String
		public let rpc: String?
		public let version: String?
	}
	struct ConfirmedBlock: Decodable {
		public let blockhash: String
		public let previousBlockhash: String
		public let parentSlot: UInt64
		public let transactions: [TransactionInfo]
		public let rewards: [Reward]
		public let blockTime: UInt64?
	}
	struct Reward: Decodable {
		public let pubkey: String
		public let lamports: Int64
		public let postBalance: UInt64
		public let rewardType: String?
	}
	struct EpochInfo: Decodable {
		public let absoluteSlot: UInt64
		public let blockHeight: UInt64
		public let epoch: UInt64
		public let slotIndex: UInt64
		public let slotsInEpoch: UInt64
	}
	struct EpochSchedule: Decodable {
		public let slotsPerEpoch: UInt64
		public let leaderScheduleSlotOffset: UInt64
		public let warmup: Bool
		public let firstNormalEpoch: UInt64
		public let firstNormalSlot: UInt64
	}
	struct Fee: Decodable {
		public let feeCalculator: FeeCalculator?
		public let feeRateGovernor: FeeRateGovernor?
		public let blockhash: String?
		public let lastValidSlot: UInt64?
	}
	struct FeeCalculator: Decodable {
		public let lamportsPerSignature: UInt64
	}
	struct FeeRateGovernor: Decodable {
		public let burnPercent: UInt64
		public let maxLamportsPerSignature: UInt64
		public let minLamportsPerSignature: UInt64
		public let targetLamportsPerSignature: UInt64
		public let targetSignaturesPerSlot: UInt64
	}
	struct Identity: Decodable {
		public let identity: String
	}
	struct InflationGovernor: Decodable {
		public let foundation: Float64
		public let foundationTerm: Float64
		public let initial: Float64
		public let taper: Float64
		public let terminal: Float64
	}
	struct InflationRate: Decodable {
		public let epoch: Float64
		public let foundation: Float64
		public let total: Float64
		public let validator: Float64
	}
	struct LargestAccount: Decodable {
		public let lamports: UInt64
		public let address: String
	}
    struct ProgramAccount<T: BufferLayout>: Decodable {
        public let account: BufferInfo<T>
		public let pubkey: String
	}
    
    struct BufferInfo<T: BufferLayout>: Decodable {
        public let lamports: UInt64
        public let owner: String
        public let data: Buffer<T>
        public let executable: Bool
        public let rentEpoch: UInt64
    }
    
	struct PerformanceSample: Decodable {
		public let numSlots: UInt64
		public let numTransactions: UInt64
		public let samplePeriodSecs: UInt
		public let slot: UInt64
	}
    struct SignatureInfo: Decodable, Hashable {
        public let signature: String
        public let slot: UInt64?
        public let err: TransactionError?
        public let memo: String?
        
        public init(signature: String) {
            self.signature = signature
            self.slot = nil
            self.err = nil
            self.memo = nil
        }
    }
	struct SignatureStatus: Decodable {
		public let slot: UInt64
		public let confirmations: UInt64?
		public let err: TransactionError?
	}
    struct TransactionInfo: Decodable {
        public let blockTime: UInt64?
        public let meta: TransactionMeta?
        public let transaction: SolanaSDK.ConfirmedTransaction
        public let slot: UInt64?
    }
    struct TransactionMeta: Decodable {
        public let err: TransactionError?
        public let fee: UInt64?
        public let innerInstructions: [InnerInstruction]?
        public let logMessages: [String]?
        public let postBalances: [UInt64]?
        public let postTokenBalances: [TokenBalance]?
        public let preBalances: [UInt64]?
        public let preTokenBalances: [TokenBalance]?
    }
    struct TransactionError: Decodable, Hashable {
        
    }
    struct InnerInstruction: Decodable {
        let index: UInt32
        let instructions: [ParsedInstruction]
    }
    struct TokenBalance: Decodable {
        let accountIndex: UInt64
        let mint: String
        let uiTokenAmount: TokenAccountBalance
    }
    struct TransactionStatus: Decodable {
        public let err: TransactionError?
        public let logs: [String]
    }
	struct StakeActivation: Decodable {
		public let active: UInt64
		public let inactive: UInt64
		public let state: String
	}
	struct Supply: Decodable {
		public let circulating: UInt64
		public let nonCirculating: UInt64
		public let nonCirculatingAccounts: [String]
		public let total: UInt64
	}
	struct TokenAccountBalance: Codable, Equatable, Hashable {
		public let uiAmount: Float64?
		public let amount: String
		public let decimals: UInt8?
        public let uiAmountString: String?
        
        public var amountInUInt64: UInt64? {
            return UInt64(amount)
        }
	}
    struct TokenAccount<T: BufferLayout>: Decodable {
		public let pubkey: String
		public let account: BufferInfo<T>
	}
	struct TokenAmount: Decodable {
		public let address: String?
		public let amount: String
		public let decimals: UInt8
		public let uiAmount: Float64
	}
	struct Version: Decodable {
		public let solanaCore: String

		private enum CodingKeys : String, CodingKey {
			case solanaCore = "solana-core"
		}
	}
	struct VoteAccounts: Decodable {
		public let current: [VoteAccount]
		public let delinquent: [VoteAccount]
	}
	struct VoteAccount: Decodable {
		public let commission: Int
		public let epochVoteAccount: Bool
		public let epochCredits: [[UInt64]]
		public let nodePubkey: String
		public let lastVote: UInt64
		public let activatedStake: UInt64
		public let votePubkey: String
	}
}
