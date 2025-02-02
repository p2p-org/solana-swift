import Foundation

public protocol SolanaAPIClient {
    /// The endpoint that indicates the rpcpool address and network
    var endpoint: APIEndPoint { get }

    // MARK: -  API Methods

    /// Returns all information associated with the account of provided Pubkey
    /// - Parameters:
    ///  - account: Pubkey of account to query, as base-58 encoded string
    /// - Throws: APIClientError
    /// - Returns The result will be an BufferInfo
    /// - SeeAlso https://docs.solana.com/developing/clients/jsonrpc-api#getaccountinfo
    ///
    func getAccountInfo<T: BufferLayout>(account: String) async throws -> BufferInfo<T>?

    /// Returns all information associated with the account of provided Pubkey
    /// - Parameters:
    ///  - account: Pubkey of account to query, as base-58 encoded string
    /// - Throws: APIClientError
    /// - Returns The result will be an BufferInfo
    /// - SeeAlso https://docs.solana.com/developing/clients/jsonrpc-api#getaccountinfo
    @available(*, deprecated, renamed: "getAccountInfo")
    func getAccountInfoThrowable<T: BufferLayout>(account: String) async throws -> BufferInfo<T>

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
    /// - Returns The result field will be an array of u64 integers listing confirmed blocks starting at start_slot for
    /// up to limit blocks, inclusive
    /// - SeeAlso https://docs.solana.com/developing/clients/jsonrpc-api#getconfirmedblockswithlimit
    ///
    func getConfirmedBlocksWithLimit(startSlot: UInt64, limit: UInt64) async throws -> [UInt64]

    /// Returns identity and transaction information about a confirmed block in the ledger
    /// - Parameters:
    ///  - slot: slot, as u64 integer
    ///  - encoding: encoding for each returned Transaction, either "json", "jsonParsed", "base58" (slow), "base64"
    ///     If parameter not provided, the default encoding is "json".
    ///     "jsonParsed" encoding attempts to use program-specific instruction parsers to return more human-readable and
    /// explicit data in the transaction.message.instructions list.
    ///     If "jsonParsed" is requested but a parser cannot be found, the instruction falls back to regular JSON
    /// encoding (accounts, data, and programIdIndex fields)
    /// - Throws: APIClientError
    /// - Returns The result field will be an ConfirmedBlock object
    /// - SeeAlso https://docs.solana.com/developing/clients/jsonrpc-api#getconfirmedblock
    ///
    func getConfirmedBlock(slot: UInt64, encoding: String) async throws -> ConfirmedBlock

    /// Get all confirmed signature for an address
    /// - Parameters:
    ///   - account: address that involved in transactions
    ///   - startSlot: start slot
    ///   - endSlot: end slot
    /// - Returns: array of transactionSignatures
    func getConfirmedSignaturesForAddress(account: String, startSlot: UInt64, endSlot: UInt64) async throws -> [String]

    /// Returns information about the current epoch
    /// - Parameters:
    ///  - commitment: Optional
    /// - Throws: APIClientError
    /// - Returns The result field will be an array of u64 integers listing confirmed blocks starting at start_slot for
    /// up to limit blocks, inclusive
    /// - SeeAlso https://docs.solana.com/developing/clients/jsonrpc-api#getepochinfo
    ///
    func getEpochInfo(commitment: Commitment?) async throws -> EpochInfo

    /// Returns a recent block hash from the ledger, a fee schedule that can be used to compute the cost of submitting a
    /// transaction using it, and the last slot in which the blockhash will be valid.
    /// - Parameters:
    ///  - commitment: Optional
    /// - Throws: APIClientError
    /// - Returns The result field will be an array of u64 integers listing confirmed blocks starting at start_slot for
    /// up to limit blocks, inclusive
    /// - SeeAlso https://docs.solana.com/developing/clients/jsonrpc-api#getfees
    ///
    func getFees(commitment: Commitment?) async throws -> Fee
    
    /// Get the fee the network will charge for a particular Message
    /// - Parameters:
    ///  -  message: Base-64 encoded Message
    ///  - commitment: Optional
    /// - Throws: ApiClientError
    /// - Returns Fee corresponding to the message at the specified blockhash
    /// - SeeAlso https://solana.com/docs/rpc/http/getfeeformessage
    /// - Note: This method is only available in solana-core v1.9 or newer.
    /// Please use ``getFees(commitment:)`` for solana-core v1.8 and below.
    ///
    func getFeeForMessage(message: String, commitment: Commitment?) async throws -> Lamports

    /// Returns minimum balance required to make account rent exempt
    /// - Parameters:
    ///  - dataLength: account data length
    ///  - commitment: Optional
    /// - Throws: APIClientError
    /// - Returns minimum lamports required in account
    /// - SeeAlso https://docs.solana.com/developing/clients/jsonrpc-api#getminimumbalanceforrentexemption
    ///
    func getMinimumBalanceForRentExemption(dataLength: UInt64, commitment: Commitment?) async throws -> UInt64

    /// Returns the statuses of a list of signatures. Unless the searchTransactionHistory configuration parameter is
    /// included,
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
    func getTokenAccountsByDelegate<T: TokenAccountLayoutState>(
        pubkey: String,
        mint: String?,
        programId: String?,
        configs: RequestConfiguration?
    ) async throws -> [TokenAccount<T>]

    /// Returns all SPL Token accounts by token owner
    /// - Parameters:
    ///  - pubkey: Pubkey of account owner to query, as base-58 encoded string
    ///  - params:Pubkey of the specific token Mint to limit accounts to, as base-58 encoded string; or Pubkey of the
    /// Token program ID that owns the accounts, as base-58 encoded string
    ///  - configs: (optional) RequestConfiguration
    /// - Throws: APIClientError
    /// - Returns The result will be an array of TokenAccount<AccountInfo>
    /// - SeeAlso https://docs.solana.com/developing/clients/jsonrpc-api#gettokenaccountsbyowner
    ///
    func getTokenAccountsByOwner<T: TokenAccountLayoutState>(
        pubkey: String,
        params: OwnerInfoParams?,
        configs: RequestConfiguration?,
        decodingTo: T.Type
    ) async throws -> [TokenAccount<T>]

    /// Returns the 20 largest accounts of a particular SPL Token type
    /// - Parameters:
    ///  - pubkey: Pubkey of token Mint to query, as base-58 encoded string
    ///  - commitment: (optional) Commitment
    /// - Throws: APIClientError
    /// - Returns The result will be an array of TokenAccount
    /// - SeeAlso https://docs.solana.com/developing/clients/jsonrpc-api#gettokenlargestaccounts
    ///
    func getTokenLargestAccounts(pubkey: String, commitment: Commitment?) async throws -> [TokenAmount]

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

    /// Returns the lowest slot that the node has information about in its ledger. This value may increase over time if
    /// the node is configured to purge older ledger data
    /// - Throws: APIClientError
    /// - Returns Minimum ledger slot
    /// - SeeAlso https://docs.solana.com/developing/clients/jsonrpc-api#minimumledgerslot
    ///
    func minimumLedgerSlot() async throws -> UInt64
    func requestAirdrop(account: String, lamports: UInt64, commitment: Commitment?) async throws -> String

    /// Submits a signed transaction to the cluster for processing.
    /// This method does not alter the transaction in any way; it relays the transaction created by clients to the node
    /// as-is.
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
    func getMultipleAccounts<T: BufferLayout>(pubkeys: [String], commitment: Commitment) async throws
        -> [BufferInfo<T>?]

    /// Observe status of a sending transaction by periodically calling getSignatureStatuses
    /// - Parameters:
    ///  - signature: signature of the transaction, as base-58 encoded strings
    ///  - timeout: timeout (in seconds)
    ///  - delay: delay between requests
    /// - Throws: APIClientError
    /// - SeeAlso https://docs.solana.com/developing/clients/jsonrpc-api#getsignaturestatuses
    ///
    func observeSignatureStatus(signature: String, timeout: Int, delay: Int) -> AsyncStream<PendingTransactionStatus>

    /// Returns a recent block hash from the ledger, and a fee schedule that can be used to compute the cost of
    /// submitting a transaction using it.
    /// - Parameters:
    ///  - commitment: (optional) Commitment
    /// - Throws: APIClientError
    /// - SeeAlso https://docs.solana.com/developing/clients/jsonrpc-api#getrecentblockhash
    ///
    func getRecentBlockhash(commitment: Commitment?) async throws -> String
    
    /// Returns the latest blockhash
    /// - Parameters:
    ///  - commitment: (optional) Commitment
    /// - Throws: APIClientError
    /// - SeeAlso https://solana.com/docs/rpc/http/getlatestblockhash
    /// - Note: This method is only available in solana-core v1.9 or newer.
    /// Please use ``getRecentBlockhash(commitment:)`` for solana-core v1.8 and below.
    ///
    func getLatestBlockhash(commitment: Commitment?) async throws -> String

    /// Returns signatures for confirmed transactions that include the given address in their accountKeys list.
    /// Returns signatures backwards in time from the provided signature or most recent confirmed block
    /// - Parameters:
    ///  - address: account address as base-58 encoded string
    ///  - configs: (optional) Configuration object
    /// - Throws: APIClientError
    /// - SeeAlso https://docs.solana.com/developing/clients/jsonrpc-api#getrecentblockhash
    ///
    func getSignaturesForAddress(address: String, configs: RequestConfiguration?) async throws -> [SignatureInfo]

    /// Returns transaction details for a confirmed transaction
    /// - Parameters:
    ///   - signature: transaction signature
    ///   - commitment: "processed" is not supported. If parameter not provided, the default is "finalized".
    /// - Returns:
    /// - Throws:
    func getTransaction(signature: String, commitment: Commitment?) async throws -> TransactionInfo?

    /// Generic methods for methods that is not on the list above
    /// - Parameters:
    ///   - method: name of the method
    ///   - params: the parameters
    /// - Returns: result of the request
    func request<Entity: Decodable>(method: String, params: [Encodable]) async throws -> Entity

    // MARK: - Batch request

    /// Perform a multiple requests at once
    /// - Parameter requests: the requests
    /// - Returns: the result of mutiple requests
    func batchRequest(with requests: [JSONRPCRequestEncoder.RequestType]) async throws
        -> [AnyResponse<JSONRPCRequestEncoder.RequestType.Entity>]

    /// Perform a multiple same returning type requests at once
    ///
    /// - Experiment: Will be changed in future.
    /// - Parameter method: method name
    /// - Parameter params: params
    /// - Returns: the result of mutiple requests
    func batchRequest<Entity: Decodable>(method: String, params: [[Encodable]]) async throws -> [Entity?]

    /// Returns a list of recent performance samples, in reverse slot order.
    /// Performance samples are taken every 60 seconds and include the number of transactions and slots that occur in a
    /// given time window.
    /// - Parameters:
    ///  - limit: number of samples to return (maximum 720)
    /// - Throws: APIClientError
    /// - SeeAlso https://docs.solana.com/developing/clients/jsonrpc-api#getrecentperformancesamples
    ///
    func getRecentPerformanceSamples(limit: [UInt]) async throws -> [PerfomanceSamples]

    // TODO: full implement
    func getSlot() async throws -> UInt64

    func getAddressLookupTable(accountKey: PublicKey) async throws -> AddressLookupTableAccount?
}
