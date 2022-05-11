import Foundation

import XCTest
@testable import SolanaSwift

class BlockchainClientTests: XCTestCase {
    var lamportsPerSignature: UInt64 { 5000 }
    var minRentExemption: UInt64 { 2039280 }
    
    var accountStorage: InMemoryAccountStorage!
    
    override func setUp() async throws {
        accountStorage = InMemoryAccountStorage()
        let account = try await Account(
            phrase: "miracle pizza supply useful steak border same again youth silver access hundred"
                .components(separatedBy: " "),
            network: .mainnetBeta
        )
        try accountStorage.save(account)
    }
    
    override func tearDown() async throws {
        accountStorage = nil
    }
    
    // MARK: - Testcases
    
    func testPrepareSendingNativeSOL() async throws {
        let account = accountStorage.account!
        let toPublicKey = "6QuXb6mB6WmRASP2y8AavXh6aabBXEH5ZzrSH5xRrgSm"
        let apiClient = MockAPIClient(testCase: #function)
        let blockchain = BlockchainClient(apiClient: apiClient)
        
        let tx = try await blockchain.prepareSendingNativeSOL(from: account,
                                                              to: toPublicKey,
                                                              amount: 100,
                                                              feePayer: account.publicKey)
        
        let recentBlockhash = try await apiClient.getRecentBlockhash()
        let serializedTransaction = try blockchain.signAndSerialize(preparedTransaction: tx, recentBlockhash: recentBlockhash)
        
        XCTAssertEqual(tx.expectedFee, .init(transaction: 5000, accountBalances: 0))
        XCTAssertEqual(serializedTransaction, "AYqN18ZDaJtv61HxaIUnmtK0f+ST/HaO3YzAOBjwtG9Qf/Td58DSe5zS5nyx9InT+UyLIZbb4nFE/XYrWfHKCwQBAAEDJ/e5BFWJMqaTuN1LbmcQ3ile94QrPqzzX8y+j5kQCsVQai+mnMv4ueKX0uXJIyAIv0UeTX3PGhu9bYIRBgH+2gAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAuN92Q8S3ViiBKFjrCz0SjRSx6JhG5pY6fuBlpw98caYBAgIAAQwCAAAAZAAAAAAAAAA=")
    }
    
    func testPrepareSendingSPLTokens() async throws {
        let account = accountStorage.account!
        
        // USDC
        let mintAddress = "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v"
        let source = "3uetDDizgTtadDHZzyy9BqxrjQcozMEkxzbKhfZF4tG3"
        
        let apiClient = MockAPIClient(testCase: #function + "#1")
        let blockchainClient = BlockchainClient(apiClient: apiClient)
        
        // Test1: for address that has no funds
        let tx = try await blockchainClient.prepareSendingSPLTokens(
            account: account,
            mintAddress: mintAddress,
            decimals: 6,
            from: source,
            to: "6QuXb6mB6WmRASP2y8AavXh6aabBXEH5ZzrSH5xRrgSm",
            amount: Double(0.001).toLamport(decimals: 6)
        )
            .preparedTransaction
        
        XCTAssertEqual(tx.expectedFee, .init(transaction: 5000, accountBalances: 2039280))
        
        let recentBlockhash = try await apiClient.getRecentBlockhash()
        let serializedTransaction = try blockchainClient.signAndSerialize(preparedTransaction: tx, recentBlockhash: recentBlockhash)
        XCTAssertEqual(serializedTransaction, "AYMEskYoYyUUFfAOOBVge/ZvKsdnThz6h8SD9fjwhMrlzdyJqOHWd1E/TNwtASCdkG2tb6+mKwvPbTmfvpDJ/gUBAAYJJ/e5BFWJMqaTuN1LbmcQ3ile94QrPqzzX8y+j5kQCsV6z8KtZmvbVqZpAcS9akND4i7DwzOEXd14OkugPk5Sjis0aQm3mACZwx0qmTJR8WAhAmhoXy0B+vDEdgGHBP5sUGovppzL+Lnil9LlySMgCL9FHk19zxobvW2CEQYB/trG+nrzvtutOj1l82qryXQxsbvkwtL24OR8pgIDRS9dYQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABt324ddloZPZy+FGzut5rBy0he1fWzeROoz1hX7/AKkGp9UXGSxcUSGMyUw9SvF/WNruCJuh/UTj29mKAAAAAIyXJY9OJInxuz0QKRSODYMLWhOZ2v8QhASOe9jb6fhZfhq5F8HYKBbSm7geKKfkJABMkKQSWgrHSxAVWNN0/7wCCAcAAQMEBQYHAAYDAgEACQPoAwAAAAAAAA==")
        
        // Test2: for address that has no funds but has usdc
        
    }
    
    let json: [String: String] = [
        "prepareSendingNativeSOL": "AbGldIcg+coxW3idbrOM6lGA6hfBozLGcQwNUSc7fFWnHipqUS2H78BeTkBjnHLcVEBHsfaigKnhfycpVFuhDQwBAAEDUGovppzL+Lnil9LlySMgCL9FHk19zxobvW2CEQYB/ton97kEVYkyppO43UtuZxDeKV73hCs+rPNfzL6PmRAKxQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAjmPmh7ra9WkvBCyAZ3QzuN3hIn6PwTtCRCylLM5r3cQBAgIAAQwCAAAAAAAAAAAAAAA="
    ]
}

private class MockAPIClient: SolanaAPIClient {
    let testCase: String
    
    init(testCase: String) {
        self.testCase = testCase
    }
    
    var endpoint: APIEndPoint {
        fatalError()
    }
    
    func getAccountInfo<T>(account: String) async throws -> BufferInfo<T>? where T : DecodableBufferLayout {
        if account == "6QuXb6mB6WmRASP2y8AavXh6aabBXEH5ZzrSH5xRrgSm" {
            let data: T
            switch testCase {
            case "testPrepareSendingNativeSOL()":
                data = EmptyInfo() as! T
            case "testPrepareSendingSPLTokens()#1":
                throw SolanaError.couldNotRetrieveAccountInfo
            default:
                fatalError()
            }
            return BufferInfo<T>(lamports: 0, owner: SystemProgram.id.base58EncodedString, data: data, executable: true, rentEpoch: 0)
        }
        if account == "9GQV3bQP9tv7m6XgGMaixxEeEdxtFhwgABw2cxCFZoch" {
            throw SolanaError.couldNotRetrieveAccountInfo
        }
        fatalError()
    }
    
    func getBalance(account: String, commitment: Commitment?) async throws -> UInt64 {
        fatalError()
    }
    
    func getBlockCommitment(block: UInt64) async throws -> BlockCommitment {
        fatalError()
    }
    
    func getBlockTime(block: UInt64) async throws -> Date {
        fatalError()
    }
    
    func getClusterNodes() async throws -> [ClusterNodes] {
        fatalError()
    }
    
    func getBlockHeight() async throws -> UInt64 {
        fatalError()
    }
    
    func getConfirmedBlocksWithLimit(startSlot: UInt64, limit: UInt64) async throws -> [UInt64] {
        fatalError()
    }
    
    func getConfirmedBlock(slot: UInt64, encoding: String) async throws -> ConfirmedBlock {
        fatalError()
    }
    
    func getConfirmedSignaturesForAddress(account: String, startSlot: UInt64, endSlot: UInt64) async throws -> [String] {
        fatalError()
    }
    
    func getEpochInfo(commitment: Commitment?) async throws -> EpochInfo {
        fatalError()
    }
    
    func getFees(commitment: Commitment?) async throws -> Fee {
        let blockhash: String
        switch testCase {
        case "testPrepareSendingNativeSOL()":
            blockhash = "DSfeYUm7WDw1YnKodR361rg8sUzUCGdat9V7fSKPFgzq"
        case "testPrepareSendingSPLTokens()#1":
            blockhash = "9VG1E6DTdjRRx2JpbXrH9QPTQQ6FRjakvStttnmSV7fR"
        default:
            fatalError()
        }
        return .init(feeCalculator: .init(lamportsPerSignature: 5000), feeRateGovernor: nil, blockhash: blockhash, lastValidSlot: 133389328)
    }
    
    func getSignatureStatuses(signatures: [String], configs: RequestConfiguration?) async throws -> [SignatureStatus?] {
        fatalError()
    }
    
    func getSignatureStatus(signature: String, configs: RequestConfiguration?) async throws -> SignatureStatus {
        fatalError()
    }
    
    func getTokenAccountBalance(pubkey: String, commitment: Commitment?) async throws -> TokenAccountBalance {
        fatalError()
    }
    
    func getTokenAccountsByDelegate(pubkey: String, mint: String?, programId: String?, configs: RequestConfiguration?) async throws -> [TokenAccount<AccountInfo>] {
        fatalError()
    }
    
    func getTokenAccountsByOwner(pubkey: String, params: OwnerInfoParams?, configs: RequestConfiguration?) async throws -> [TokenAccount<AccountInfo>] {
        fatalError()
    }
    
    func getTokenLargestAccounts(pubkey: String, commitment: Commitment?) async throws -> [TokenAmount] {
        fatalError()
    }
    
    func getTokenSupply(pubkey: String, commitment: Commitment?) async throws -> TokenAmount {
        fatalError()
    }
    
    func getVersion() async throws -> Version {
        fatalError()
    }
    
    func getVoteAccounts(commitment: Commitment?) async throws -> VoteAccounts {
        fatalError()
    }
    
    func minimumLedgerSlot() async throws -> UInt64 {
        fatalError()
    }
    
    func requestAirdrop(account: String, lamports: UInt64, commitment: Commitment?) async throws -> String {
        fatalError()
    }
    
    func sendTransaction(transaction: String, configs: RequestConfiguration) async throws -> TransactionID {
        fatalError()
    }
    
    func simulateTransaction(transaction: String, configs: RequestConfiguration) async throws -> SimulationResult {
        fatalError()
    }
    
    func setLogFilter(filter: String) async throws -> String? {
        fatalError()
    }
    
    func validatorExit() async throws -> Bool {
        fatalError()
    }
    
    func getMultipleAccounts<T>(pubkeys: [String]) async throws -> [BufferInfo<T>] where T : DecodableBufferLayout {
        fatalError()
    }
    
    func getRecentBlockhash(commitment: Commitment?) async throws -> String {
        switch testCase {
        case "testPrepareSendingNativeSOL()":
            return "DSfeYUm7WDw1YnKodR361rg8sUzUCGdat9V7fSKPFgzq"
        case "testPrepareSendingSPLTokens()#1":
            return "9VG1E6DTdjRRx2JpbXrH9QPTQQ6FRjakvStttnmSV7fR"
        default:
            fatalError()
        }
        fatalError()
    }
    
    func observeSignatureStatus(signature: String, timeout: Int, delay: Int) -> AsyncStream<TransactionStatus> {
        fatalError()
    }
    
    func getMinimumBalanceForRentExemption(dataLength: UInt64, commitment: Commitment?) async throws -> UInt64 {
        2039280
    }
}
