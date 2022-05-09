import XCTest
@testable import SolanaSwift

class ObserveTransactionStatusTests: XCTestCase {
    enum CustomError: Error {
        case unknownNetworkError
    }
    
    let endpoint = APIEndPoint(
        address: "https://api.mainnet-beta.solana.com",
        network: .mainnetBeta
    )
    
    func testObservingTransactionStatus() async throws {
        let mock = NetworkManagerMock([
            .success(mockResponse(confirmations: 0, confirmationStatus: "processed")),
            .failure(CustomError.unknownNetworkError),
            .success(mockResponse(confirmations: 1, confirmationStatus: "confirmed")),
            .failure(CustomError.unknownNetworkError),
            .failure(SolanaError.unknown),
            .success(mockResponse(confirmations: 5, confirmationStatus: "confirmed")),
            .success(mockResponse(confirmations: 10, confirmationStatus: "confirmed")),
            .failure(SolanaError.unknown),
            .success(mockResponse(confirmations: nil, confirmationStatus: "finalized")),
        ])
        let apiClient = SolanaSwift.JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)
        
        var statuses = [TransactionStatus]()
        
        // Test 1, timeout 5
        for try await status in apiClient.observeSignatureStatus(signature: "jaiojsdfoijvaij", timeout: 5, delay: 1) {
            statuses.append(status)
        }
        print(statuses)
        XCTAssertEqual(statuses.last?.numberOfConfirmations, 1)

        // Test 2, timeout 7
        statuses = []
        for try await status in apiClient.observeSignatureStatus(signature: "jijviajidsfjiaj", timeout: 7, delay: 1) {
            statuses.append(status)
        }
        print(statuses)
        XCTAssertEqual(statuses.last?.numberOfConfirmations, 10)
        
        // Test 3, default timeout (60)
        statuses = []
        for try await status in apiClient.observeSignatureStatus(signature: "jijviajidsfjiaj") {
            statuses.append(status)
        }
        print(statuses)
        XCTAssertEqual(statuses.last, .finalized)
    }
    
    // MARK: - Helpers
    
    func mockResponse(confirmations: Int?, confirmationStatus: String) -> String {
        #"[{"jsonrpc":"2.0","result":{"context":{"slot":82},"value":[{"slot":72,"confirmations":\#(confirmations != nil ? "\(confirmations!)": "null"),"err":null,"status":{"Ok":null},"confirmationStatus":"\#(confirmationStatus)"},null]},"id":1}]"#
    }
    
    class NetworkManagerMock: NetworkManager {
        private var count = 0
        private let results: [Result<String, Error>]
        
        init(_ results: [Result<String, Error>]) {
            self.results = results
        }
        
        func requestData(request: URLRequest) async throws -> Data {
            try await Task.sleep(nanoseconds: 1000000000)
            switch results[count] {
            case .success(let string):
                let data = string.data(using: .utf8)!
                count += 1
                return data
            case .failure(let error):
                count += 1
                throw error
            }
        }
    }
}
