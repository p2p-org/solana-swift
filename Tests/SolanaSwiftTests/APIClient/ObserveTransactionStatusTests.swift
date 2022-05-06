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
            .success(#""#),
            .failure(CustomError.unknownNetworkError),
            .success(#""#),
            .failure(CustomError.unknownNetworkError),
            .failure(SolanaError.unknown),
            .success(#""#),
            .success(#""#),
            .success(#""#),
            .success(#""#)
        ])
        let apiClient = SolanaSwift.JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)
        let result = try! await apiClient.getBlockHeight()
        XCTAssertEqual(result, 119396901)
    }
    
    class NetworkManagerMock: NetworkManager {
        private var count = 0
        private let results: [Result<String, Error>]
        
        init(_ results: [Result<String, Error>]) {
            self.results = results
        }
        
        func requestData(request: URLRequest) async throws -> Data {
            switch results[count] {
            case .success(let string):
                let data = string.data(using: .utf8)!
                count += 1
                return data
            case .failure(let error):
                print(error.localizedDescription)
                count += 1
                throw error
            }
        }
    }
}
