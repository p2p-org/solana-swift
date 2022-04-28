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
	}
    struct ResponseError: Decodable {
        public init(code: Int?, message: String?, data: SolanaSDK.ResponseErrorData?) {
            self.code = code
            self.message = message
            self.data = data
        }
        
		public let code: Int?
		public let message: String?
        public let data: ResponseErrorData?
	}
    struct ResponseErrorData: Decodable {
        // public let err: ResponseErrorDataError
        public let logs: [String]?
        public let numSlotsBehind: Int?
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
	struct ClusterNode: Decodable {
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
		public let lamports: Lamports
		public let postBalance: Lamports
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
		public let feeCalculator: FeeCalculatorResponse?
		public let feeRateGovernor: FeeRateGovernor?
		public let blockhash: String?
		public let lastValidSlot: UInt64?
	}
	struct FeeCalculatorResponse: Decodable {
		public let lamportsPerSignature: Lamports
	}
	struct FeeRateGovernor: Decodable {
		public let burnPercent: UInt64
		public let maxLamportsPerSignature: Lamports
		public let minLamportsPerSignature: Lamports
		public let targetLamportsPerSignature: Lamports
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
		public let lamports: Lamports
		public let address: String
	}
    
    struct ProgramAccounts<T: DecodableBufferLayout>: Decodable {
        public let accounts: [ProgramAccount<T>]
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let throwables = try container.decode([Throwable<ProgramAccount<T>>].self)
            
            var accounts = [ProgramAccount<T>]()
            throwables.forEach {
                switch $0.result {
                case .success(let account):
                    accounts.append(account)
                case .failure(let error):
                    Logger.log(message: "Error decoding an account in program accounts list: \(error.localizedDescription)", event: .error)
                }
            }
            self.accounts = accounts
        }
    }
    
    struct ProgramAccount<T: DecodableBufferLayout>: Decodable {
        public let account: BufferInfo<T>
		public let pubkey: String
	}
    
    struct BufferInfo<T: DecodableBufferLayout>: Decodable {
        public let lamports: Lamports
        public let owner: String
        public let data: T
        public let executable: Bool
        public let rentEpoch: UInt64
    }
    
	struct PerformanceSample: Decodable {
		public let numSlots: UInt64
		public let numTransactions: UInt64
		public let samplePeriodSecs: UInt
		public let slot: UInt64
	}
    struct SignatureInfo: Decodable {
        public let signature: String
        public let slot: UInt64?
        public let err: TransactionError?
        public let memo: String?
		public let blockTime: UInt64?
        
        public init(signature: String) {
            self.signature = signature
            self.slot = nil
            self.err = nil
            self.memo = nil
			self.blockTime = nil
        }
    }
	struct SignatureStatus: Decodable {
		public let slot: UInt64
		public let confirmations: UInt64?
		public let err: TransactionError?
        public let confirmationStatus: String?
	}
    struct TransactionInfo: Decodable {
        public let blockTime: UInt64?
        public let meta: TransactionMeta?
        public let transaction: SolanaSDK.ConfirmedTransaction
        public let slot: UInt64?
    }
    struct TransactionMeta: Decodable {
        public let err: TransactionError?
        public let fee: Lamports?
        public let innerInstructions: [InnerInstruction]?
        public let logMessages: [String]?
        public let postBalances: [Lamports]?
        public let postTokenBalances: [TokenBalance]?
        public let preBalances: [Lamports]?
        public let preTokenBalances: [TokenBalance]?
    }
    typealias TransactionError = [String: [ErrorDetail]]
    struct ErrorDetail: Codable {
        let wrapped: Any
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let value = try? container.decode(Bool.self) {
                wrapped = value
            } else if let value = try? container.decode(Double.self) {
                wrapped = value
            } else if let value = try? container.decode(String.self) {
                wrapped = value
            } else if let value = try? container.decode(Int.self) {
                wrapped = value
            } else if let value = try? container.decode(Dictionary<String, Int>.self) {
                wrapped = value
            } else {
                wrapped = ""
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            if let wrapped = wrapped as? Encodable {
                let wrapper = EncodableWrapper(wrapped: wrapped)
                try container.encode(wrapper)
            }
        }
    }
    
    struct InnerInstruction: Decodable {
        public let index: UInt32
        public let instructions: [ParsedInstruction]
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
		public let circulating: Lamports
		public let nonCirculating: Lamports
		public let nonCirculatingAccounts: [String]
		public let total: Lamports
	}
    struct TokenAccountBalance: Codable, Equatable, Hashable {
        init(uiAmount: Float64?, amount: String, decimals: UInt8?, uiAmountString: String?) {
            self.uiAmount = uiAmount
            self.amount = amount
            self.decimals = decimals
            self.uiAmountString = uiAmountString
        }
        
        init(amount: String, decimals: UInt8?) {
            self.uiAmount = UInt64(amount)?.convertToBalance(decimals: decimals)
            self.amount = amount
            self.decimals = decimals
            self.uiAmountString = "\(uiAmount ?? 0)"
        }
        
		public let uiAmount: Float64?
		public let amount: String
		public let decimals: UInt8?
        public let uiAmountString: String?
        
        public var amountInUInt64: UInt64? {
            return UInt64(amount)
        }
	}
    struct TokenAccount<T: DecodableBufferLayout>: Decodable {
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
