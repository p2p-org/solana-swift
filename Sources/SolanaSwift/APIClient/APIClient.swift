import Foundation
import RxSwift

public protocol SolanaAPIClient {
    associatedtype RequestEncoder: APIClientRequestEncoder

    // MARK: -  API Methods
    
    /// Returns all information associated with the account of provided Pubkey
    /// - Parameters:
    ///  - account: Pubkey of account to query, as base-58 encoded string
    /// - Throws: APIClientError
    /// - Returns The result will be an BufferInfo
    /// - SeeAlso https://docs.solana.com/developing/clients/jsonrpc-api#getaccountinfo
    ///
    func getAccountInfo<T: DecodableBufferLayout>(account: String) async throws -> BufferInfo<T>?

    /// Returns the balance of the account of provided Pubkey
    /// - Parameters:
    ///  - account: Pubkey of account to query, as base-58 encoded string
    ///  - commitment: Optional
    /// - Throws: APIClientError
    /// - Returns The result will be an UInt64 balance value
    /// - SeeAlso https://docs.solana.com/developing/clients/jsonrpc-api#getbalance
    ///
    func getBalance(account: String, commitment: Commitment?) async throws -> UInt64
    
    /// Returns commitment for particular block
    /// - Parameters:
    ///  - block:  block, identified by Slot
    /// - Throws: APIClientError
    /// - Returns The result will be BlockCommitment
    /// - SeeAlso https://docs.solana.com/developing/clients/jsonrpc-api#getblockcommitment
    ///
    func getBlockCommitment(block: UInt64) async throws -> BlockCommitment
    
    /// Returns the estimated production time of a block
    /// - Parameters:
    ///  - block:  block, identified by Slot
    /// - Throws: APIClientError
    /// - Returns Estimated production date
    /// - SeeAlso https://docs.solana.com/developing/clients/jsonrpc-api#getblocktime
    ///
    func getBlockTime(block: UInt64) async throws -> Date
    
    /// Returns information about all the nodes participating in the cluster
    /// - Throws: APIClientError
    /// - Returns The result field will be an array of ClusterNodes
    /// - SeeAlso https://docs.solana.com/developing/clients/jsonrpc-api#getclusternodes
    ///
    func getClusterNodes() async throws -> [ClusterNodes]
    
    /// Returns the current block height of the node
    /// - Throws: APIClientError
    /// - Returns Current block height
    /// - SeeAlso https://docs.solana.com/developing/clients/jsonrpc-api#getblockheight
    ///
    func getBlockHeight() async throws -> UInt64
    
    /// Returns a list of confirmed blocks starting at the given slot
    /// - Parameters:
    ///  - startSlot: start_slot, as u64 integer
    ///  - limit: as u64 integer
    /// - Throws: APIClientError
    /// - Returns The result field will be an array of u64 integers listing confirmed blocks starting at start_slot for up to limit blocks, inclusive
    /// - SeeAlso https://docs.solana.com/developing/clients/jsonrpc-api#getconfirmedblockswithlimit
    ///
    func getConfirmedBlocksWithLimit(startSlot: UInt64, limit: UInt64) async throws -> [UInt64]
    
    /// Returns identity and transaction information about a confirmed block in the ledger
    /// - Parameters:
    ///  - slot: slot, as u64 integer
    ///  - encoding: encoding for each returned Transaction, either "json", "jsonParsed", "base58" (slow), "base64"
    ///     If parameter not provided, the default encoding is "json".
    ///     "jsonParsed" encoding attempts to use program-specific instruction parsers to return more human-readable and explicit data in the transaction.message.instructions list.
    ///     If "jsonParsed" is requested but a parser cannot be found, the instruction falls back to regular JSON encoding (accounts, data, and programIdIndex fields)
    /// - Throws: APIClientError
    /// - Returns The result field will be an ConfirmedBlock object
    /// - SeeAlso https://docs.solana.com/developing/clients/jsonrpc-api#getconfirmedblock
    ///
    func getConfirmedBlock(slot: UInt64, encoding: String) async throws -> ConfirmedBlock
    func getConfirmedSignaturesForAddress(account: String, startSlot: UInt64, endSlot: UInt64) async throws -> [String]

    /// Returns information about the current epoch
    /// - Parameters:
    ///  - commitment: Optional
    /// - Throws: APIClientError
    /// - Returns The result field will be an array of u64 integers listing confirmed blocks starting at start_slot for up to limit blocks, inclusive
    /// - SeeAlso https://docs.solana.com/developing/clients/jsonrpc-api#getepochinfo
    ///
    func getEpochInfo(commitment: Commitment?) async throws -> EpochInfo
    
    /// Returns a recent block hash from the ledger, a fee schedule that can be used to compute the cost of submitting a transaction using it, and the last slot in which the blockhash will be valid.
    /// - Parameters:
    ///  - commitment: Optional
    /// - Throws: APIClientError
    /// - Returns The result field will be an array of u64 integers listing confirmed blocks starting at start_slot for up to limit blocks, inclusive
    /// - SeeAlso https://docs.solana.com/developing/clients/jsonrpc-api#getfees
    ///
    func getFees(commitment: Commitment?) async throws -> Fee
    
    /// Returns minimum balance required to make account rent exempt
    /// - Parameters:
    ///  - dataLength: account data length
    ///  - commitment: Optional
    /// - Throws: APIClientError
    /// - Returns minimum lamports required in account
    /// - SeeAlso https://docs.solana.com/developing/clients/jsonrpc-api#getminimumbalanceforrentexemption
    ///
    func getMinimumBalanceForRentExemption(dataLength: UInt64, commitment: Commitment?) async throws -> UInt64
    
    /// Returns the statuses of a list of signatures. Unless the searchTransactionHistory configuration parameter is included,
    /// this method only searches the recent status cache of signatures,
    /// which retains statuses for all active slots plus MAX_RECENT_BLOCKHASHES rooted slots.
    /// - Parameters:
    ///  - signatures: An array of transaction signatures to confirm, as base-58 encoded strings
    ///  - configs: (optional) Configuration object
    /// - Throws: APIClientError
    /// - Returns minimum lamports required in account
    /// - SeeAlso https://docs.solana.com/developing/clients/jsonrpc-api#getsignaturestatuses
    ///
    func getSignatureStatuses(signatures: [String], configs: RequestConfiguration?) async throws -> [SignatureStatus?]
    /// - SeeAlso getSignatureStatuses(signatures: , configs:) async throws -> [SignatureStatus?]
    func getSignatureStatus(signature: String, configs: RequestConfiguration?) async throws -> SignatureStatus
    
    /// Returns the token balance of an SPL Token account
    /// - Parameters:
    ///  - pubkey: Pubkey of Token account to query, as base-58 encoded string
    ///  - commitment: Optional
    /// - Throws: APIClientError
    /// - Returns The result will be an TokenAccountBalance
    /// - SeeAlso https://docs.solana.com/developing/clients/jsonrpc-api#gettokenaccountbalance
    ///
    func getTokenAccountBalance(pubkey: String, commitment: Commitment?) async throws -> TokenAccountBalance
    
    /// Returns all SPL Token accounts by approved Delegate
    /// - Parameters:
    ///  - pubkey: Pubkey of account delegate to query, as base-58 encoded string
    ///  - mint: (optional) Pubkey of the specific token Mint to limit accounts to, as base-58 encoded string;
    ///  - programId: (optional)  Pubkey of the Token program ID that owns the accounts, as base-58 encoded string
    ///  - configs: (optional) Configuration object
    /// - Throws: APIClientError
    /// - Returns The result will be an array of TokenAccount<AccountInfo>
    /// - SeeAlso https://docs.solana.com/developing/clients/jsonrpc-api#gettokenaccountsbydelegate
    ///
    func getTokenAccountsByDelegate(pubkey: String, mint: String?, programId: String?, configs: RequestConfiguration?) async throws -> [TokenAccount<AccountInfo>]
    
    /// Returns all SPL Token accounts by token owner
    /// - Parameters:
    ///  - pubkey: Pubkey of account owner to query, as base-58 encoded string
    ///  - params:Pubkey of the specific token Mint to limit accounts to, as base-58 encoded string; or Pubkey of the Token program ID that owns the accounts, as base-58 encoded string
    ///  - configs: (optional) RequestConfiguration
    /// - Throws: APIClientError
    /// - Returns The result will be an array of TokenAccount<AccountInfo>
    /// - SeeAlso https://docs.solana.com/developing/clients/jsonrpc-api#gettokenaccountsbyowner
    ///
    func getTokenAccountsByOwner(pubkey: String, params: OwnerInfoParams?, configs: RequestConfiguration?) async throws -> [TokenAccount<AccountInfo>]
    
    /// Returns the 20 largest accounts of a particular SPL Token type
    /// - Parameters:
    ///  - pubkey: Pubkey of token Mint to query, as base-58 encoded string
    ///  - commitment: (optional) Commitment
    /// - Throws: APIClientError
    /// - Returns The result will be an array of TokenAccount
    /// - SeeAlso https://docs.solana.com/developing/clients/jsonrpc-api#gettokenlargestaccounts
    ///
    func getTokenLargestAccounts(pubkey: String, commitment: Commitment?)  async throws -> [TokenAmount]
    
    /// Returns the total supply of an SPL Token type
    /// - Parameters:
    ///  - pubkey: Pubkey of token Mint to query, as base-58 encoded string
    ///  - commitment: (optional) Commitment
    /// - Throws: APIClientError
    /// - Returns The result will be a TokenAmount
    /// - SeeAlso https://docs.solana.com/developing/clients/jsonrpc-api#gettokensupply
    ///
    func getTokenSupply(pubkey: String, commitment: Commitment?) async throws -> TokenAmount
    
    /// Returns the current solana versions running on the node
    /// - Throws: APIClientError
    /// - Returns The result field will be a Version
    /// - SeeAlso https://docs.solana.com/developing/clients/jsonrpc-api#getversion
    ///
    func getVersion() async throws -> Version
    
    /// Returns the account info and associated stake for all the voting accounts in the current bank
    /// - Parameters:
    ///  - commitment: (optional) Commitment
    /// - Throws: APIClientError
    /// - Returns The result field will be a VoteAccounts
    /// - SeeAlso https://docs.solana.com/developing/clients/jsonrpc-api#getvoteaccounts
    ///
    func getVoteAccounts(commitment: Commitment?) async throws -> VoteAccounts
    
    /// Returns the lowest slot that the node has information about in its ledger. This value may increase over time if the node is configured to purge older ledger data
    /// - Throws: APIClientError
    /// - Returns Minimum ledger slot
    /// - SeeAlso https://docs.solana.com/developing/clients/jsonrpc-api#minimumledgerslot
    ///
    func minimumLedgerSlot() async throws -> UInt64
    func requestAirdrop(account: String, lamports: UInt64, commitment: Commitment?) async throws -> String
    
    /// Submits a signed transaction to the cluster for processing.
    /// This method does not alter the transaction in any way; it relays the transaction created by clients to the node as-is.
    /// - Parameters:
    ///  - transaction: fully-signed Transaction, as encoded string
    ///  - configs: Configuration object
    /// - Throws: APIClientError
    /// - Returns First Transaction Signature embedded in the transaction, as base-58 encoded string
    /// - SeeAlso https://docs.solana.com/developing/clients/jsonrpc-api#sendtransaction
    ///
    func sendTransaction(transaction: String, configs: RequestConfiguration) async throws -> TransactionID
    
    /// Simulate sending a transaction
    /// - Parameters:
    ///  - serializedTransaction: fully-signed Transaction, as encoded string
    ///  - configs: Configuration object
    /// - Throws: APIClientError
    /// - Returns First Transaction Signature embedded in the transaction, as base-58 encoded string
    /// - SeeAlso https://docs.solana.com/developing/clients/jsonrpc-api#simulatetransaction
    ///
    func simulateTransaction(transaction: String, configs: RequestConfiguration) async throws -> SimulationResult
    func setLogFilter(filter: String) async throws -> String?
    func validatorExit() async throws -> Bool
    
    /// Returns the account information for a list of Pubkeys
    /// - Parameters:
    ///  - pubkeys: An array of Pubkeys to query, as base-58 encoded strings
    /// - Throws: APIClientError
    /// - Returns The result will be an RpcResponse
    /// - SeeAlso https://docs.solana.com/developing/clients/jsonrpc-api#getmultipleaccounts
    ///
    func getMultipleAccounts<T: DecodableBufferLayout>(pubkeys: [String]) async throws -> [BufferInfo<T>]
    
    /// Observe status of a sending transaction by periodically calling getSignatureStatuses
    /// - Parameters:
    ///  - signature: signature of the transaction, as base-58 encoded strings
    ///  - timeout: timeout (in seconds)
    ///  - delay: delay between requests
    /// - Throws: APIClientError
    /// - SeeAlso https://docs.solana.com/developing/clients/jsonrpc-api#getsignaturestatuses
    ///
    func observeSignatureStatus(signature: String, timeout: Int, delay: Int) -> AsyncStream<TransactionStatus>

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
    
    public func getMinimumBalanceForRentExemption(span: UInt64) async throws -> UInt64 {
        try await self.getMinimumBalanceForRentExemption(dataLength: span)
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
}
