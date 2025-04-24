import Foundation

import XCTest
@testable import SolanaSwift

class BlockchainClientWithNativeSOLTests: XCTestCase {
    var account: KeyPair!

    override func setUp() async throws {
        account = try await KeyPair(
            phrase: "miracle pizza supply useful steak border same again youth silver access hundred"
                .components(separatedBy: " "),
            network: .mainnetBeta
        )
    }

    override func tearDown() async throws {
        account = nil
    }

    // MARK: - Testcases

    func testPrepareSendingNativeSOL() async throws {
        let toPublicKey = "6QuXb6mB6WmRASP2y8AavXh6aabBXEH5ZzrSH5xRrgSm"
        let apiClient = MockAPIClient(testCase: #function)
        let blockchain = BlockchainClient(apiClient: apiClient)

        let tx = try await blockchain.prepareSendingNativeSOL(
            from: account,
            to: toPublicKey,
            amount: 100,
            feePayer: account.publicKey
        )

        let recentBlockhash = try await apiClient.getRecentBlockhash()
        let serializedTransaction = try blockchain.signAndSerialize(
            preparedTransaction: tx,
            recentBlockhash: recentBlockhash
        )

        XCTAssertEqual(tx.expectedFee, .init(transaction: 5000, accountBalances: 0))
        XCTAssertEqual(
            serializedTransaction,
            "AYqN18ZDaJtv61HxaIUnmtK0f+ST/HaO3YzAOBjwtG9Qf/Td58DSe5zS5nyx9InT+UyLIZbb4nFE/XYrWfHKCwQBAAEDJ/e5BFWJMqaTuN1LbmcQ3ile94QrPqzzX8y+j5kQCsVQai+mnMv4ueKX0uXJIyAIv0UeTX3PGhu9bYIRBgH+2gAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAuN92Q8S3ViiBKFjrCz0SjRSx6JhG5pY6fuBlpw98caYBAgIAAQwCAAAAZAAAAAAAAAA="
        )
    }

    func testPrepareSendingNativeSOLToNewlyCreatedAccount() async throws {
        let toPublicKey = "6QuXb6mB6WmRASP2y8AavXh6aabBXEH5ZzrSH5xRrgSm"
        let apiClient = MockAPIClient(testCase: #function)
        let blockchain = BlockchainClient(apiClient: apiClient)

        let tx = try await blockchain.prepareSendingNativeSOL(
            from: account,
            to: toPublicKey,
            amount: 100,
            feePayer: account.publicKey
        )

        let recentBlockhash = try await apiClient.getRecentBlockhash()
        let serializedTransaction = try blockchain.signAndSerialize(
            preparedTransaction: tx,
            recentBlockhash: recentBlockhash
        )

        XCTAssertEqual(tx.expectedFee, .init(transaction: 5000, accountBalances: 0))
        XCTAssertEqual(
            serializedTransaction,
            "AYqN18ZDaJtv61HxaIUnmtK0f+ST/HaO3YzAOBjwtG9Qf/Td58DSe5zS5nyx9InT+UyLIZbb4nFE/XYrWfHKCwQBAAEDJ/e5BFWJMqaTuN1LbmcQ3ile94QrPqzzX8y+j5kQCsVQai+mnMv4ueKX0uXJIyAIv0UeTX3PGhu9bYIRBgH+2gAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAuN92Q8S3ViiBKFjrCz0SjRSx6JhG5pY6fuBlpw98caYBAgIAAQwCAAAAZAAAAAAAAAA="
        )
    }
}

private class MockAPIClient: SolanaAPIClient {
    let testCase: String

    init(testCase: String) {
        self.testCase = testCase
    }

    var endpoint: APIEndPoint {
        fatalError()
    }

    func getAccountInfo<T>(account: String) async throws -> BufferInfo<T>? where T: BufferLayout {
        let data: T
        let lamports: Lamports
        let owner: String
        let executable: Bool
        let rentEpoch: UInt64

        switch account {
        case "6QuXb6mB6WmRASP2y8AavXh6aabBXEH5ZzrSH5xRrgSm":
            switch testCase {
            case "testPrepareSendingNativeSOL()":
                data = EmptyInfo() as! T
                lamports = 0
                owner = SystemProgram.id.base58EncodedString
                executable = true
                rentEpoch = 0
            case "testPrepareSendingNativeSOLToNewlyCreatedAccount()":
                return nil
            case "testPrepareSendingSPLTokens()#1":
                throw APIClientError.couldNotRetrieveAccountInfo
            case "testPrepareSendingSPLTokens()#2":
                throw APIClientError.couldNotRetrieveAccountInfo
            case "testPrepareSendingSPLTokens()#4":
                throw APIClientError.couldNotRetrieveAccountInfo
            default:
                fatalError()
            }
        case "9GQV3bQP9tv7m6XgGMaixxEeEdxtFhwgABw2cxCFZoch":
            switch testCase {
            case "testPrepareSendingSPLTokens()#2", "testPrepareSendingSPLTokens()#4",
                 "testPrepareSendingSPLTokens()#5":
                data = TokenAccountState(
                    mint: "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v",
                    owner: "6QuXb6mB6WmRASP2y8AavXh6aabBXEH5ZzrSH5xRrgSm",
                    lamports: 100,
                    delegateOption: 0,
                    isInitialized: true,
                    isFrozen: false,
                    state: 0,
                    isNativeOption: 0,
                    rentExemptReserve: nil,
                    isNativeRaw: 0,
                    isNative: false,
                    delegatedAmount: 0,
                    closeAuthorityOption: 0
                ) as! T
                lamports = 0
                owner = TokenProgram.id.base58EncodedString
                executable = true
                rentEpoch = 0
            default:
                throw APIClientError.couldNotRetrieveAccountInfo
            }
        case "G3s9UyAY7hCwrghDMyurVtPk3wy8CV6hi8haWGLdbdTc":
            throw APIClientError.couldNotRetrieveAccountInfo
        case "5n3vrofk2Cj2zEUm7Bq4eT6GNbw8Hyq8EFdWJX2yXPbh":
            throw APIClientError.couldNotRetrieveAccountInfo
        case "":
            return nil
        default:
            fatalError()
        }
        return BufferInfo<T>(lamports: lamports, owner: owner, data: data, executable: executable, rentEpoch: rentEpoch)
    }

    func getFees(commitment _: Commitment?) async throws -> Fee {
        let blockhash: String
        let lastValidSlot: UInt64
        switch testCase {
        case "testPrepareSendingNativeSOL()":
            blockhash = "DSfeYUm7WDw1YnKodR361rg8sUzUCGdat9V7fSKPFgzq"
            lastValidSlot = 133_389_328
        case "testPrepareSendingNativeSOLToNewlyCreatedAccount()":
            blockhash = "7GhCDV2MK7RVhYzD3iNZAVkCd9hYCgyqkgXdFbEFj9PD"
            lastValidSlot = 133_389_328
        case "testPrepareSendingSPLTokens()#1":
            blockhash = "9VG1E6DTdjRRx2JpbXrH9QPTQQ6FRjakvStttnmSV7fR"
            lastValidSlot = 133_389_328
        case "testPrepareSendingSPLTokens()#2":
            blockhash = "3uRa2bbJgTKVEKmZqKRtfWfhZF5YMn4D9xE64NYvTh4v"
            lastValidSlot = 133_389_328
        case "testPrepareSendingSPLTokens()#3":
            blockhash = "4VXrgGDjah4rCo2bvqSWXJTLbaDkmn4NTXknLn9GzacN"
            lastValidSlot = 133_458_521
        case "testPrepareSendingSPLTokens()#4":
            blockhash = "Bc11qGhSE3Vham6cBWEUxhRVVSNtzkyisdGGXwh6hvnT"
            lastValidSlot = 133_461_545
        case "testPrepareSendingSPLTokens()#5":
            blockhash = "7GhCDV2MK7RVhYzD3iNZAVkCd9hYCgyqkgXdFbEFj9PD"
            lastValidSlot = 133_461_991

        default:
            fatalError()
        }
        return .init(
            feeCalculator: .init(lamportsPerSignature: 5000),
            feeRateGovernor: nil,
            blockhash: blockhash,
            lastValidSlot: lastValidSlot
        )
    }
    
    func getFeeForMessage(message _: String, commitment _: Commitment?) async throws -> Lamports {
        return 1337
    }

    func getRecentBlockhash(commitment _: Commitment?) async throws -> String {
        switch testCase {
        case "testPrepareSendingNativeSOL()":
            return "DSfeYUm7WDw1YnKodR361rg8sUzUCGdat9V7fSKPFgzq"
        case "testPrepareSendingNativeSOLToNewlyCreatedAccount()":
            return "DSfeYUm7WDw1YnKodR361rg8sUzUCGdat9V7fSKPFgzq"
        case "testPrepareSendingSPLTokens()#1":
            return "9VG1E6DTdjRRx2JpbXrH9QPTQQ6FRjakvStttnmSV7fR"
        case "testPrepareSendingSPLTokens()#2":
            return "3uRa2bbJgTKVEKmZqKRtfWfhZF5YMn4D9xE64NYvTh4v"
        case "testPrepareSendingSPLTokens()#3":
            return "4VXrgGDjah4rCo2bvqSWXJTLbaDkmn4NTXknLn9GzacN"
        case "testPrepareSendingSPLTokens()#4":
            return "Bc11qGhSE3Vham6cBWEUxhRVVSNtzkyisdGGXwh6hvnT"
        case "testPrepareSendingSPLTokens()#5":
            return "7GhCDV2MK7RVhYzD3iNZAVkCd9hYCgyqkgXdFbEFj9PD"
        default:
            fatalError()
        }
    }
    
    func getLatestBlockhash(commitment _: Commitment?) async throws -> String {
        return "Bc11qGhSE3Vham6cBWEUxhRVVSNtzkyisdGGXwh6hvnT"
    }

    func getMinimumBalanceForRentExemption(dataLength _: UInt64, commitment _: Commitment?) async throws -> UInt64 {
        2_039_280
    }

    func getBalance(account _: String, commitment _: Commitment?) async throws -> UInt64 {
        fatalError()
    }

    func getBlockCommitment(block _: UInt64) async throws -> BlockCommitment {
        fatalError()
    }

    func getBlockTime(block _: UInt64) async throws -> Date {
        fatalError()
    }

    func getClusterNodes() async throws -> [ClusterNodes] {
        fatalError()
    }

    func getBlockHeight() async throws -> UInt64 {
        fatalError()
    }

    func getConfirmedBlocksWithLimit(startSlot _: UInt64, limit _: UInt64) async throws -> [UInt64] {
        fatalError()
    }

    func getConfirmedBlock(slot _: UInt64, encoding _: String) async throws -> ConfirmedBlock {
        fatalError()
    }

    func getConfirmedSignaturesForAddress(account _: String, startSlot _: UInt64,
                                          endSlot _: UInt64) async throws -> [String]
    {
        fatalError()
    }

    func getEpochInfo(commitment _: Commitment?) async throws -> EpochInfo {
        fatalError()
    }

    func getSignatureStatuses(signatures _: [String],
                              configs _: RequestConfiguration?) async throws -> [SignatureStatus?]
    {
        fatalError()
    }

    func getSignatureStatus(signature _: String, configs _: RequestConfiguration?) async throws -> SignatureStatus {
        fatalError()
    }

    func getTokenAccountBalance(pubkey _: String, commitment _: Commitment?) async throws -> TokenAccountBalance {
        fatalError()
    }

    func getTokenAccountsByDelegate<T: TokenAccountLayoutState>(
        pubkey _: String,
        mint _: String?,
        programId _: String?,
        configs _: RequestConfiguration?
    ) async throws -> [TokenAccount<T>] {
        fatalError()
    }

    func getTokenAccountsByOwner<T: TokenAccountLayoutState>(
        pubkey _: String,
        params _: OwnerInfoParams?,
        configs _: RequestConfiguration?,
        decodingTo _: T.Type
    ) async throws -> [TokenAccount<T>] {
        fatalError()
    }

    func getTokenLargestAccounts(pubkey _: String, commitment _: Commitment?) async throws -> [TokenAmount] {
        fatalError()
    }

    func getTokenSupply(pubkey _: String, commitment _: Commitment?) async throws -> TokenAmount {
        fatalError()
    }

    func getVersion() async throws -> Version {
        fatalError()
    }

    func getVoteAccounts(commitment _: Commitment?) async throws -> VoteAccounts {
        fatalError()
    }

    func minimumLedgerSlot() async throws -> UInt64 {
        fatalError()
    }

    func requestAirdrop(account _: String, lamports _: UInt64, commitment _: Commitment?) async throws -> String {
        fatalError()
    }

    func sendTransaction(transaction _: String, configs _: RequestConfiguration) async throws -> TransactionID {
        fatalError()
    }

    func simulateTransaction(transaction _: String, configs _: RequestConfiguration) async throws -> SimulationResult {
        fatalError()
    }

    func setLogFilter(filter _: String) async throws -> String? {
        fatalError()
    }

    func validatorExit() async throws -> Bool {
        fatalError()
    }

    func getMultipleAccounts<T>(pubkeys _: [String], commitment _: Commitment) async throws -> [BufferInfo<T>?]
        where T: BufferLayout
    {
        fatalError()
    }

    func observeSignatureStatus(signature _: String, timeout _: Int,
                                delay _: Int) -> AsyncStream<PendingTransactionStatus>
    {
        fatalError()
    }

    func getSignaturesForAddress(address _: String, configs _: RequestConfiguration?) async throws -> [SignatureInfo] {
        fatalError()
    }

    func getTransaction(signature _: String, commitment _: Commitment?) async throws -> TransactionInfo? {
        fatalError()
    }

    func request<Entity>(method _: String, params _: [Encodable]) async throws -> Entity where Entity: Decodable {
        fatalError()
    }

    func batchRequest(with _: [JSONRPCRequestEncoder.RequestType]) async throws
        -> [AnyResponse<JSONRPCRequestEncoder.RequestType.Entity>]
    {
        fatalError()
    }

    func batchRequest<Entity>(method _: String, params _: [[Encodable]]) async throws -> [Entity?]
        where Entity: Decodable
    {
        fatalError()
    }

    func getRecentPerformanceSamples(limit _: [UInt]) async throws -> [SolanaSwift.PerfomanceSamples] {
        fatalError()
    }

    func getSlot() async throws -> UInt64 {
        0
    }

    func getAddressLookupTable(accountKey _: SolanaSwift.PublicKey) async throws -> SolanaSwift
        .AddressLookupTableAccount?
    {
        nil
    }
}
