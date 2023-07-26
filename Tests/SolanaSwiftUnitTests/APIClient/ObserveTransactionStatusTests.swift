@testable import SolanaSwift
import XCTest

class ObserveTransactionStatusTests: XCTestCase {
    enum CustomError: Error {
        case unknownNetworkError
    }

    let endpoint = APIEndPoint(
        address: "https://api.mainnet-beta.solana.com",
        network: .mainnetBeta
    )

    var apiClient: JSONRPCAPIClient!
    var statuses: [PendingTransactionStatus]!

    override func setUpWithError() throws {
        resetAPIClient()
    }

    override func tearDownWithError() throws {
        apiClient = nil
        statuses = []
    }

    func testObservingTransactionStatusExceededTimeout1() async throws {
        // Test 1, timeout 5
        for try await status in apiClient.observeSignatureStatus(signature: "jaiojsdfoijvaij", timeout: 5, delay: 1) {
            print(status)
            statuses.append(status)
        }
        XCTAssertEqual(statuses.last?.numberOfConfirmations, 1)
    }

    func testObservingTransactionStatusExceededTimeout2() async throws {
        for try await status in apiClient.observeSignatureStatus(signature: "jijviajidsfjiaj", timeout: 7, delay: 1) {
            print(status)
            statuses.append(status)
        }
        XCTAssertEqual(statuses.last?.numberOfConfirmations, 10)
    }

    func testObservingTransactionStatusFinalized() async throws {
        for try await status in apiClient.observeSignatureStatus(signature: "jijviajidsfjiaj", delay: 1) {
            print(status)
            statuses.append(status)
        }
        XCTAssertEqual(statuses.last, .finalized)
    }

    func testWaitForConfirmationIgnoreStatus() async throws {
        // return anyway after time out, even when transaction is not surely confimed
        let response: [Result<String, Error>] = [
            .failure(CustomError.unknownNetworkError),
            .failure(CustomError.unknownNetworkError),
            .failure(APIClientError.invalidResponse),
            .success(mockResponse(confirmations: 5, confirmationStatus: "confirmed")),
            .success(mockResponse(confirmations: 10, confirmationStatus: "confirmed")),
            .failure(APIClientError.invalidResponse),
            .success(mockResponse(confirmations: nil, confirmationStatus: "finalized")),
        ]

        resetAPIClient(customResponse: response)
        try await apiClient.waitForConfirmation(signature: "adfijidjfaisdf", ignoreStatus: true, timeout: 1, delay: 1)

        resetAPIClient(customResponse: response)
        try await apiClient.waitForConfirmation(signature: "adfijidjfaisdf", ignoreStatus: true)
    }

    func testWaitForConfirmationNotIgnoreStatus() async throws {
        // return only if transaction is confirmed or partially confirmed
        let response: [Result<String, Error>] = [
            .failure(CustomError.unknownNetworkError),
            .failure(CustomError.unknownNetworkError),
            .failure(APIClientError.invalidResponse),
            .success(mockResponse(confirmations: 5, confirmationStatus: "confirmed")),
            .success(mockResponse(confirmations: 10, confirmationStatus: "confirmed")),
            .failure(APIClientError.invalidResponse),
            .success(mockResponse(confirmations: nil, confirmationStatus: "finalized")),
        ]

        resetAPIClient(customResponse: response)
        do {
            try await apiClient.waitForConfirmation(
                signature: "adfijidjfaisdf",
                ignoreStatus: true,
                timeout: 1,
                delay: 1
            )
        } catch {
            XCTAssertTrue(error.isEqualTo(TransactionConfirmationError.unconfirmed))
        }

        resetAPIClient(customResponse: response)
        do {
            try await apiClient.waitForConfirmation(
                signature: "adfijidjfaisdf",
                ignoreStatus: true,
                timeout: 3,
                delay: 1
            )
        } catch {
            XCTAssertTrue(error.isEqualTo(TransactionConfirmationError.unconfirmed))
        }

        resetAPIClient(customResponse: response)
        try await apiClient.waitForConfirmation(signature: "adfijidjfaisdf", ignoreStatus: true, timeout: 7, delay: 1)

        resetAPIClient(customResponse: response)
        try await apiClient.waitForConfirmation(signature: "adfijidjfaisdf", ignoreStatus: true, delay: 1)
    }

    private func resetAPIClient(customResponse: [Result<String, Error>]? = nil) {
        let mock = NetworkManagerMock(customResponse ?? [
            .success(mockResponse(confirmations: 0, confirmationStatus: "processed")),
            .failure(CustomError.unknownNetworkError),
            .success(mockResponse(confirmations: 1, confirmationStatus: "confirmed")),
            .failure(CustomError.unknownNetworkError),
            .failure(APIClientError.invalidResponse),
            .success(mockResponse(confirmations: 5, confirmationStatus: "confirmed")),
            .success(mockResponse(confirmations: 10, confirmationStatus: "confirmed")),
            .failure(APIClientError.invalidResponse),
            .success(mockResponse(confirmations: nil, confirmationStatus: "finalized")),
        ])
        apiClient = JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)
        statuses = []
    }

    // MARK: - Helpers

    func mockResponse(confirmations: Int?, confirmationStatus: String) -> String {
        #"{"jsonrpc":"2.0","result":{"context":{"slot":82},"value":[{"slot":72,"confirmations":\#(confirmations != nil ? "\(confirmations!)" : "null"),"err":null,"status":{"Ok":null},"confirmationStatus":"\#(confirmationStatus)"},null]},"id":1}"#
    }

    class NetworkManagerMock: NetworkManager {
        fileprivate var count = 0
        private let results: [Result<String, Error>]

        init(_ results: [Result<String, Error>]) {
            self.results = results
        }

        func requestData(request _: URLRequest) async throws -> Data {
            switch results[count] {
            case let .success(string):
                let data = string.data(using: .utf8)!
                count += 1
                return data
            case let .failure(error):
                count += 1
                throw error
            }
        }
    }
}
