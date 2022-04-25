import Foundation

public extension SolanaSDK {
    typealias Lamports = SolanaSwift.Lamports
    typealias Decimals = SolanaSwift.Decimals
    typealias TokenAccountBalance = SolanaSwift.TokenAccountBalance
    typealias TransactionID = SolanaSwift.TransactionID
    typealias SignatureStatus = SolanaSwift.SignatureStatus
    typealias Rpc = SolanaSwift.Rpc
    typealias BufferInfo = SolanaSwift.BufferInfo
    typealias SignatureInfo = SolanaSwift.SignatureInfo
    typealias Response = SolanaSwift.Response
    // Network
    typealias Network = SolanaSwift.Network
    // Pool
    typealias Pool = SolanaSwift.Pool
    // PreparedTransaction
    typealias PreparedTransaction = SolanaSwift.PreparedTransaction
    // PublicKey
    typealias PublicKey = SolanaSwift.PublicKey
    typealias TransactionInstruction = SolanaSwift.TransactionInstruction
    typealias Wallet = SolanaSwift.Wallet

    typealias FeeAmount = SolanaSwift.FeeAmount
    typealias DerivablePath = SolanaSwift.DerivablePath
    typealias ConfirmedTransaction = SolanaSwift.ConfirmedTransaction
    typealias ParsedInstruction = SolanaSwift.ParsedInstruction
    typealias APIEndPoint = SolanaSwift.APIEndPoint
    typealias Account = SolanaSwift.Account

    // MARK: -  Solana Token
    typealias TokenTag = SolanaSwift.TokenTag
    typealias WrappingToken = SolanaSwift.WrappingToken
    typealias Token = SolanaSwift.Token
    typealias TokenExtensions = SolanaSwift.TokenExtensions
    
    // MARK: - SendingTransaction
    typealias Transaction = SolanaSwift.Transaction

    // MARK: - BufferLayout
    typealias AccountInfo = SolanaSwift.AccountInfo
    typealias EmptyInfo = SolanaSwift.EmptyInfo
    typealias Mint = SolanaSwift.Mint
    typealias TokenSwapInfo = SolanaSwift.TokenSwapInfo
}
