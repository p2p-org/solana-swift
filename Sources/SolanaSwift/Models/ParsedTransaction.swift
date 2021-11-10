//
//  ParsedTransaction.swift
//  SolanaSwift
//
//  Created by Chung Tran on 05/04/2021.
//

import Foundation

public extension SolanaSDK {
    struct ParsedTransaction: Hashable {
        public enum Status: Equatable, Hashable {
            case requesting
            case processing(percent: Double)
            case confirmed
            case error(String?)
            
            public func getError() -> Error? {
                var error: Error?
                switch self {
                case .error(let err) where err != nil:
                    return Error.other(err!)
                default:
                    break
                }
                return nil
            }
            
            public var rawValue: String {
                switch self {
                case .requesting:
                    return "requesting"
                case .processing:
                    return "processing"
                case .confirmed:
                    return "confirmed"
                case .error:
                    return "error"
                }
            }
        }
        
        public init(status: Status, signature: String?, value: AnyHashable?, amountInFiat: Double? = nil, slot: UInt64?, blockTime: Date?, fee: UInt64?, blockhash: String?) {
            self.status = status
            self.signature = signature
            self.value = value
            self.amountInFiat = amountInFiat
            self.slot = slot
            self.blockTime = blockTime
            self.fee = fee
            self.blockhash = blockhash
        }
        
        public var status: Status
        public var signature: String?
        public var value: AnyHashable?
        public var amountInFiat: Double?
        public let slot: UInt64?
        public var blockTime: Date?
        public let fee: UInt64?
        public let blockhash: String?
        
        public var amount: Double {
            switch value {
            case let transaction as CreateAccountTransaction:
                return -(transaction.fee ?? 0)
            case let transaction as CloseAccountTransaction:
                return transaction.reimbursedAmount ?? 0
            case let transaction as TransferTransaction:
                var amount = transaction.amount ?? 0
                if transaction.transferType == .send {
                    amount = -amount
                }
                return amount
            case let transaction as SwapTransaction:
                var amount = 0.0
                switch transaction.direction {
                case .spend:
                    amount = -(transaction.sourceAmount ?? 0)
                case .receive:
                    amount = transaction.destinationAmount ?? 0
                case .transitiv:
                    amount = transaction.destinationAmount ?? 0
                }
                return amount
            default:
                return 0
            }
        }
        
        public var symbol: String {
            switch value {
            case is CreateAccountTransaction, is CloseAccountTransaction:
                return "SOL"
            case let transaction as TransferTransaction:
                return transaction.source?.token.symbol ?? transaction.destination?.token.symbol ?? ""
            case let transaction as SwapTransaction:
                switch transaction.direction {
                case .spend:
                    return transaction.source?.token.symbol ?? ""
                case .receive:
                    return transaction.destination?.token.symbol ?? ""
                case .transitiv:
                    return transaction.destination?.token.symbol ?? ""
                }
            default:
                return ""
            }
        }
        
        public var isProcessing: Bool {
            switch status {
            case .requesting, .processing:
                return true
            default:
                return false
            }
        }
        
        public var isFailure: Bool {
            switch status {
            case .error:
                return true
            default:
                return false
            }
        }
    }
    
    struct CreateAccountTransaction: Hashable {
        public let fee: Double? // in SOL
        public let newWallet: Wallet?
        
        static var empty: Self {
            CreateAccountTransaction(fee: nil, newWallet: nil)
        }
    }
    
    struct CloseAccountTransaction: Hashable {
        public init(reimbursedAmount: Double?, closedWallet: SolanaSDK.Wallet?) {
            self.reimbursedAmount = reimbursedAmount
            self.closedWallet = closedWallet
        }
        
        public let reimbursedAmount: Double?
        public let closedWallet: Wallet?
    }
    
    struct TransferTransaction: Hashable {
        public init(source: SolanaSDK.Wallet?, destination: SolanaSDK.Wallet?, authority: String?, destinationAuthority: String?, amount: Double?, wasPaidByP2POrg: Bool = false, myAccount: String?) {
            self.source = source
            self.destination = destination
            self.authority = authority
            self.destinationAuthority = destinationAuthority
            self.amount = amount
            self.wasPaidByP2POrg = wasPaidByP2POrg
            self.myAccount = myAccount
        }
        
        public enum TransferType {
            case send, receive
        }
        
        public let source: Wallet?
        public let destination: Wallet?
        public let authority: String?
        public let destinationAuthority: String?
        public let amount: Double?
        public var wasPaidByP2POrg: Bool = false
        
        let myAccount: String?
        
        public var transferType: TransferType? {
            if source?.pubkey == myAccount || authority == myAccount {
                return .send
            }
            return .receive
        }
    }
    
    struct SwapTransaction: Hashable {
        public init(source: SolanaSDK.Wallet?, sourceAmount: Double?, destination: SolanaSDK.Wallet?, destinationAmount: Double?, myAccountSymbol: String?) {
            self.source = source
            self.sourceAmount = sourceAmount
            self.destination = destination
            self.destinationAmount = destinationAmount
            self.myAccountSymbol = myAccountSymbol
        }
        
        public enum Direction {
            case spend, receive, transitiv
        }
        
        // source
        public let source: Wallet?
        public let sourceAmount: Double?
        
        // destination
        public let destination: Wallet?
        public let destinationAmount: Double?
        
        public var myAccountSymbol: String?
        
        static var empty: Self {
            SwapTransaction(source: nil, sourceAmount: nil, destination: nil, destinationAmount: nil, myAccountSymbol: nil)
        }
        
        public var direction: Direction {
            if myAccountSymbol == source?.token.symbol {
                return .spend
            }
            if myAccountSymbol == destination?.token.symbol {
                return .receive
            }
            return .transitiv
        }
    }
}
