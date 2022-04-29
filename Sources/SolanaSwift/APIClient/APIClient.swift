import Foundation
import RxSwift

public protocol SolanaAPIClient {
    associatedtype RequestEncoder: APIClientRequestEncoder

    // API Methods
    func getAccountInfo<T: DecodableBufferLayout>(account: String) async throws -> BufferInfo<T>
    func getBalance(account: String, commitment: Commitment?) async throws -> UInt64
    func getBlockCommitment(block: UInt64) async throws -> BlockCommitment
    func getBlockTime(block: UInt64) async throws -> Date
    func getClusterNodes() async throws -> [ClusterNodes]
    func getBlockHeight() async throws -> UInt64
    func getConfirmedBlocksWithLimit(startSlot: UInt64, limit: UInt64) async throws -> [UInt64]
    func getConfirmedBlock(slot: UInt64, encoding: String) async throws -> ConfirmedBlock
    func getConfirmedSignaturesForAddress(account: String, startSlot: UInt64, endSlot: UInt64) async throws -> [String]
    func getEpochInfo(commitment: Commitment?) async throws -> EpochInfo
    func getFees(commitment: Commitment?) async throws -> Fee
    func getMinimumBalanceForRentExemption(dataLength: UInt64, commitment: Commitment?) async throws -> UInt64
    func getSignatureStatuses(signatures: [String], configs: RequestConfiguration?) async throws -> [SignatureStatus?]
    func getSignatureStatus(signature: String, configs: RequestConfiguration?) async throws -> SignatureStatus
    func getTokenAccountBalance(pubkey: String, commitment: Commitment?) async throws -> TokenAccountBalance
    func getTokenAccountsByDelegate(pubkey: String, mint: String?, programId: String?, configs: RequestConfiguration?) async throws -> [TokenAccount<AccountInfo>]
    func getTokenAccountsByOwner(pubkey: String, params: OwnerInfoParams?, configs: RequestConfiguration?) async throws -> [TokenAccount<AccountInfo>]
    func getTokenLargestAccounts(pubkey: String, commitment: Commitment?)  async throws -> [TokenAmount]
    func getTokenSupply(pubkey: String, commitment: Commitment?) async throws -> TokenAmount
    func getVersion() async throws -> Version
    func getVoteAccounts(commitment: Commitment?) async throws -> VoteAccounts
    func minimumLedgerSlot() async throws -> UInt64
    func requestAirdrop(account: String, lamports: UInt64, commitment: Commitment?) async throws -> String
    func sendTransaction(serializedTransaction: String, configs: RequestConfiguration) async throws -> TransactionID
    func simulateTransaction(transaction: String, configs: RequestConfiguration) async throws -> TransactionStatus
    func setLogFilter(filter: String) async throws -> String?
    func validatorExit() async throws -> Bool

    // Requests
    func request<Entity: Decodable>(with request: RequestEncoder.RequestType) async throws -> AnyResponse<Entity>
    func request(with requests: [RequestEncoder.RequestType]) async throws -> [AnyResponse<RequestEncoder.RequestType.Entity>]
}

public enum APIClientError: Error {
    case cantEncodeParams
    case invalidAPIURL
    case cantDecodeResponse
}

/// Solana API Methods
extension SolanaAPIClient {
    
    public func getAccountInfo<T: DecodableBufferLayout>(account: String) async throws -> BufferInfo<T> {
        let requestConfig = RequestConfiguration(encoding: "base64")
        let req = RequestEncoder.RequestType(method: "getAccountInfo", params: [account, requestConfig])
        let response: AnyResponse<Rpc<BufferInfo<T>>> = try await request(with: req)
        guard let ret = response.result?.value else {
            throw APIClientError.cantDecodeResponse
        }
        return ret
    }
    
    public func getBlockHeight() async throws -> UInt64 {
        return try await self.get(method: "getBlockHeight", params: [])
    }
    
    public func getConfirmedBlocksWithLimit(startSlot: UInt64, limit: UInt64) async throws -> [UInt64] {
        return try await self.get(method: "getConfirmedBlocksWithLimit", params: [startSlot, limit])
    }
    
    public func getBalance(account: String, commitment: Commitment? = nil) async throws -> UInt64 {
        let req = RequestEncoder.RequestType(method: "getBalance", params: [account, RequestConfiguration(commitment: commitment)])
        let response: AnyResponse<Rpc<UInt64>> = try await request(with: req)
        guard let result = response.result else {
            throw APIClientError.cantDecodeResponse
        }
        return result.value
    }
    
    public func getBlockCommitment(block: UInt64) async throws -> BlockCommitment {
        return try await self.get(method: "getBlockCommitment", params: [block])
    }
    
    public func getBlockTime(block: UInt64) async throws -> Date {
        let req = RequestEncoder.RequestType(method: "getBlockTime", params: [block])
        let response: AnyResponse<Double> = try await request(with: req)
        guard let resp = response.result else { throw APIClientError.cantDecodeResponse }
        return Date(timeIntervalSince1970: TimeInterval(resp))
    }
    
    public func getClusterNodes() async throws -> [ClusterNodes] {
        return try await self.get(method: "getClusterNodes", params: [])
    }
    
    public func getConfirmedBlock(slot: UInt64, encoding: String) async throws -> ConfirmedBlock {
        return try await self.get(method: "getConfirmedBlock", params: [slot, encoding])
    }
    
    public func getConfirmedSignaturesForAddress(account: String, startSlot: UInt64, endSlot: UInt64) async throws -> [String] {
        return try await self.get(method: "getConfirmedSignaturesForAddress", params: [account, startSlot, endSlot])
    }
    
    public func getTransaction(transactionSignature: String) async throws -> TransactionInfo {
        return try await self.get(method: "getTransaction", params: [transactionSignature, "jsonParsed"])
    }
    
    public func getEpochInfo(commitment: Commitment? = nil) async throws -> EpochInfo {
        return try await self.get(method: "getEpochInfo", params: [RequestConfiguration(commitment: commitment)])
    }
    
    public func getFees(commitment: Commitment? = nil) async throws -> Fee {
        return try await self.get(method: "getFees", params: [RequestConfiguration(commitment: commitment)])
    }
    
    public func getMinimumBalanceForRentExemption(dataLength: UInt64, commitment: Commitment? = "recent") async throws -> UInt64 {
        return try await self.get(method: "getMinimumBalanceForRentExemption", params: [dataLength, RequestConfiguration(commitment: commitment)])
    }
    
    public func getMinimumBalanceForRentExemption(span: UInt64) async throws -> UInt64 {
        return try await self.getMinimumBalanceForRentExemption(dataLength: span)
    }
    
    public func getRecentBlockhash(commitment: Commitment? = nil) async throws -> String {
        let result: Rpc<Fee> = try await self.get(method: "getRecentBlockhash", params: [RequestConfiguration(commitment: commitment)])
        guard let blockhash = result.value.blockhash else {
            throw SolanaSDK.Error.other("Blockhash not found")
        }
        return blockhash
    }
    
    public func getSignatureStatuses(signatures: [String], configs: RequestConfiguration? = nil) async throws -> [SignatureStatus?] {
        let result: Rpc<[SignatureStatus?]> = try await self.get(method: "getSignatureStatuses", params: [signatures, configs])
        return result.value
    }
    
    public func getSignatureStatus(signature: String, configs: RequestConfiguration? = nil) async throws -> SignatureStatus {
        guard let result = try await getSignatureStatuses(signatures: [signature]).first else {
            throw APIClientError.cantDecodeResponse
        }
        return try result ?! APIClientError.cantDecodeResponse
    }
    
    public func getTokenAccountBalance(pubkey: String, commitment: Commitment? = nil) async throws -> TokenAccountBalance {
        let result: Rpc<TokenAccountBalance> = try await self.get(method: "getTokenAccountBalance", params: [pubkey, RequestConfiguration(commitment: commitment)])
        if UInt64(result.value.amount) == nil {
            throw SolanaSDK.Error.couldNotRetrieveAccountInfo
        }
        return result.value
    }
    
    public func getTokenAccountsByDelegate(pubkey: String, mint: String? = nil, programId: String? = nil, configs: RequestConfiguration? = nil) async throws -> [TokenAccount<AccountInfo>] {
        let result: Rpc<[TokenAccount<AccountInfo>]> = try await self.get(method: "getTokenAccountsByDelegate", params: [pubkey, mint, programId, configs])
        return result.value
    }
    
    public func getTokenAccountsByOwner(pubkey: String, params: OwnerInfoParams? = nil, configs: RequestConfiguration? = nil) async throws -> [TokenAccount<AccountInfo>] {
        let result: Rpc<[TokenAccount<AccountInfo>]> = try await self.get(method: "getTokenAccountsByOwner", params: [pubkey, params, configs])
        return result.value
    }
    
    public func getTokenLargestAccounts(pubkey: String, commitment: Commitment? = nil)  async throws -> [TokenAmount] {
        let result: [TokenAmount] = try await self.get(method: "getTokenLargestAccounts", params: [pubkey, RequestConfiguration(commitment: commitment)])
        return result
    }
    
    public func getTokenSupply(pubkey: String, commitment: Commitment? = nil) async throws -> TokenAmount {
        let result: Rpc<TokenAmount> = try await self.get(method: "getTokenSupply", params: [pubkey, RequestConfiguration(commitment: commitment)])
        return result.value
    }
    
    public func getVersion() async throws -> Version {
        let result: Version = try await self.get(method: "getVersion", params: [])
        return result
    }
    
    public func getVoteAccounts(commitment: Commitment? = nil) async throws -> VoteAccounts {
        let result: VoteAccounts = try await self.get(method: "getVoteAccounts", params: [RequestConfiguration(commitment: commitment)])
        return result
    }
    
    public func minimumLedgerSlot() async throws -> UInt64 {
        let result: UInt64 = try await self.get(method: "minimumLedgerSlot", params: [])
        return result
    }
    
    public func requestAirdrop(account: String, lamports: UInt64, commitment: Commitment? = nil) async throws -> String {
        let result: String = try await self.get(method: "requestAirdrop", params: [account, lamports, RequestConfiguration(commitment: commitment)])
        return result
    }
    
    public func sendTransaction(serializedTransaction: String, configs: RequestConfiguration = RequestConfiguration(encoding: "base64")!) async throws -> TransactionID {
        let result: TransactionID = try await self.get(method: "sendTransaction", params: [serializedTransaction, configs])
        return result
    }
    
    public func simulateTransaction(transaction: String, configs: RequestConfiguration = RequestConfiguration(encoding: "base64")!) async throws -> TransactionStatus {
        let result: Rpc<TransactionStatus> = try await self.get(method: "simulateTransaction", params: [transaction, configs])
        return result.value
    }
    
    public func setLogFilter(filter: String) async throws -> String? {
        let result: String? = try await self.get(method: "setLogFilter", params: [filter])
        return result
    }
    
    public func validatorExit() async throws -> Bool {
        let result: Bool = try await self.get(method: "validatorExit", params: [])
        return result
    }
    
    // MARK: - Private
    
    private func get<Entity: Decodable>(method: String, params: [Encodable]) async throws -> Entity {
        let req = RequestEncoder.RequestType(method: method, params: params)
        let response: AnyResponse<Entity> = try await request(with: req)
        guard let result = response.result else {
            throw APIClientError.cantDecodeResponse
        }
        return result
    }
    

}
