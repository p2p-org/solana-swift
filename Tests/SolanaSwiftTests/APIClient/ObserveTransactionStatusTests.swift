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
        for try await status in apiClient.observeSignatureStatus(signature: "jaiojsdfoijvaij") {
            print(status)
        }
//        let result = try! await apiClient.getBlockHeight()
//        XCTAssertEqual(result, 119396901)
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
            if count == 1 {
                try await Task.sleep(nanoseconds: 3000000000) // 3 seconds
            }
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
