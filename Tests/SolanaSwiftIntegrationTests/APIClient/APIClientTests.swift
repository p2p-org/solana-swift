import SolanaSwift
import XCTest

class APIClientTests: XCTestCase {
    private let apiClient = JSONRPCAPIClient(endpoint: .init(address: "https://api.devnet.solana.com", network: .devnet))

    func testGenericRequest() async throws {
        let result: String = try await apiClient.request(method: "getHealth")
        XCTAssertEqual(result, "ok")
    }
}
