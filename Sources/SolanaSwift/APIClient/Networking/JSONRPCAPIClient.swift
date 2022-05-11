import Foundation
import LoggerSwift

/// JSON RPC
public class JSONRPCAPIClient: SolanaAPIClient {
    public typealias ResponseDecoder = JSONRPCResponseDecoder
    public typealias RequestEncoder = JSONRPCRequestEncoder
    
    // MARK: -
    
    public let endpoint: APIEndPoint
    private let networkManager: NetworkManager
    
    public init(endpoint: APIEndPoint, networkManager: NetworkManager = URLSession(configuration: .default)) {
        self.endpoint = endpoint
        self.networkManager = networkManager
    }
    
    // MARK: -
    
    public func getAccountInfo<T: DecodableBufferLayout>(account: String) async throws -> BufferInfo<T>? {
        let requestConfig = RequestConfiguration(encoding: "base64")
        let req = RequestEncoder.RequestType(method: "getAccountInfo", params: [account, requestConfig])
        guard let ret = try? await (request(with: req) as AnyResponse<Rpc<BufferInfo<T>?>>).result?.value else {
            throw SolanaSDK.Error.other("Could not retrieve account info")
        }
        return ret
    }
    
    public func getBlockHeight() async throws -> UInt64 {
        try await self.get(method: "getBlockHeight", params: [])
    }
    
    public func getConfirmedBlocksWithLimit(startSlot: UInt64, limit: UInt64) async throws -> [UInt64] {
        try await self.get(method: "getConfirmedBlocksWithLimit", params: [startSlot, limit])
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
        try await self.get(method: "getBlockCommitment", params: [block])
    }
    
    public func getBlockTime(block: UInt64) async throws -> Date {
        let req = RequestEncoder.RequestType(method: "getBlockTime", params: [block])
        let response: AnyResponse<Double> = try await request(with: req)
        guard let resp = response.result else { throw APIClientError.cantDecodeResponse }
        return Date(timeIntervalSince1970: TimeInterval(resp))
    }
    
    public func getClusterNodes() async throws -> [ClusterNodes] {
        try await self.get(method: "getClusterNodes", params: [])
    }
    
    public func getConfirmedBlock(slot: UInt64, encoding: String) async throws -> ConfirmedBlock {
        try await self.get(method: "getConfirmedBlock", params: [slot, encoding])
    }
    
    public func getConfirmedSignaturesForAddress(account: String, startSlot: UInt64, endSlot: UInt64) async throws -> [String] {
        try await self.get(method: "getConfirmedSignaturesForAddress", params: [account, startSlot, endSlot])
    }
    
    public func getTransaction(transactionSignature: String) async throws -> TransactionInfo {
        try await self.get(method: "getTransaction", params: [transactionSignature, "jsonParsed"])
    }
    
    public func getEpochInfo(commitment: Commitment? = nil) async throws -> EpochInfo {
        try await self.get(method: "getEpochInfo", params: [RequestConfiguration(commitment: commitment)])
    }
    
    public func getFees(commitment: Commitment? = nil) async throws -> Fee {
        let result: Rpc<Fee> = try await self.get(method: "getFees", params: [RequestConfiguration(commitment: commitment)])
        return result.value
    }
    
    public func getMinimumBalanceForRentExemption(dataLength: UInt64, commitment: Commitment? = "recent") async throws -> UInt64 {
        try await self.get(method: "getMinimumBalanceForRentExemption", params: [dataLength, RequestConfiguration(commitment: commitment)])
    }
    
    public func getRecentBlockhash(commitment: Commitment? = nil) async throws -> String {
        let result: Rpc<Fee> = try await self.get(method: "getRecentBlockhash", params: [RequestConfiguration(commitment: commitment)])
        guard let blockhash = result.value.blockhash else {
            throw SolanaError.other("Blockhash not found")
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
            throw SolanaError.couldNotRetrieveAccountInfo
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
        try await self.get(method: "getTokenLargestAccounts", params: [pubkey, RequestConfiguration(commitment: commitment)])
    }
    
    public func getTokenSupply(pubkey: String, commitment: Commitment? = nil) async throws -> TokenAmount {
        let result: Rpc<TokenAmount> = try await self.get(method: "getTokenSupply", params: [pubkey, RequestConfiguration(commitment: commitment)])
        return result.value
    }
    
    public func getVersion() async throws -> Version {
        try await self.get(method: "getVersion", params: [])
    }
    
    public func getVoteAccounts(commitment: Commitment? = nil) async throws -> VoteAccounts {
        try await self.get(method: "getVoteAccounts", params: [RequestConfiguration(commitment: commitment)])
    }
    
    public func minimumLedgerSlot() async throws -> UInt64 {
        try await self.get(method: "minimumLedgerSlot", params: [])
    }
    
    public func requestAirdrop(account: String, lamports: UInt64, commitment: Commitment? = nil) async throws -> String {
        try await self.get(method: "requestAirdrop", params: [account, lamports, RequestConfiguration(commitment: commitment)])
    }
    
    public func sendTransaction(transaction: String, configs: RequestConfiguration = RequestConfiguration(encoding: "base64")!) async throws -> TransactionID {
        try await self.get(method: "sendTransaction", params: [transaction, configs])
    }
    
    public func simulateTransaction(transaction: String, configs: RequestConfiguration = RequestConfiguration(encoding: "base64")!) async throws -> SimulationResult {
        let result: Rpc<SimulationResult> = try await self.get(method: "simulateTransaction", params: [transaction, configs])
        return result.value
    }
    
    public func observeSignatureStatus(signature: String, timeout: Int = 60, delay: Int = 2) -> AsyncStream<TransactionStatus> {
         AsyncStream { continuation in
             let monitor = TransactionMonitor(
                 apiClient: self,
                 signature: signature,
                 timeout: timeout,
                 delay: delay,
                 responseHandler: { transactionStatus in
                     continuation.yield(transactionStatus)
                     if transactionStatus == .finalized {
                         continuation.finish()
                     }
                 },
                 timedOutHandler: {
                     continuation.finish()
                 }
             )
             continuation.onTermination = { @Sendable _ in
                 monitor.stopMonitoring()
             }
             monitor.startMonitoring()
         }
     }
    
    public func setLogFilter(filter: String) async throws -> String? {
        try await self.get(method: "setLogFilter", params: [filter])
    }
    
    public func validatorExit() async throws -> Bool {
        try await self.get(method: "validatorExit", params: [])
    }
    
    public func getMultipleAccounts<T: DecodableBufferLayout>(pubkeys: [String]) async throws -> [BufferInfo<T>] {
        let configs = RequestConfiguration(encoding: "base64")
        guard !pubkeys.isEmpty else { return [] }
        let result: Rpc<[BufferInfo<T>]> = try await self.get(method: "getMultipleAccounts", params: [pubkeys, configs])
        return result.value
    }
    
    // MARK: - Private
    
    private func get<Entity: Decodable>(method: String, params: [Encodable]) async throws -> Entity {
        let req = RequestEncoder.RequestType(method: method, params: params)
        try Task.checkCancellation()
        let response: AnyResponse<Entity> = try await request(with: req)
        guard let result = response.result else {
            throw APIClientError.cantDecodeResponse
        }
        return result
    }
    
    public func request(with requests: [RequestEncoder.RequestType]) async throws -> [AnyResponse<RequestEncoder.RequestType.Entity>] {
        let data = try await self.makeRequest(requests: requests)
        
        // log
        LoggerSwift.Logger.log(event: .response, message: String(data: data, encoding: .utf8) ?? "")
        
        let response = try ResponseDecoder<[AnyResponse<AnyDecodable>]>().decode(with: data)
        let ret = response.map({ resp in
            return AnyResponse<RequestEncoder.RequestType.Entity>(resp)
        })
        return ret
    }
    
    public func request<Entity: Decodable>(with request: RequestEncoder.RequestType) async throws -> AnyResponse<Entity> {
        try ResponseDecoder<AnyResponse<Entity>>().decode(with: try await self.makeRequest(requests: [request]))
    }
    
    // MARK: - Private
    
    private func makeRequest(requests: [RequestEncoder.RequestType]) async throws -> Data {
        var encodedParams: Data = Data()
        do {
            if requests.count == 1, let request = requests.first {
                encodedParams += try RequestEncoder(request: request).encoded()
            } else {
                encodedParams += try RequestEncoder(requests: requests).encoded()
            }
        } catch {
            throw APIClientError.cantEncodeParams
        }
        return try await networkManager.requestData(request: try self.urlRequest(data: encodedParams))
    }
    
    private func urlRequest(data: Data) throws -> URLRequest {
        guard let url = URL(string: self.endpoint.getURL()) else { throw APIClientError.invalidAPIURL }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpBody = data
        urlRequest.httpMethod = "POST"
        urlRequest.headers = ["Content-Type": "application/json; charset=utf-8"]
        
        // log
        LoggerSwift.Logger.log(event: .request, message: urlRequest.cURL())
        
        return urlRequest
    }
}
