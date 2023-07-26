@testable import SolanaSwift
import XCTest

class APIClientSendTransactionTests: XCTestCase {
    let endpoint = APIEndPoint(
        address: "https://api.mainnet-beta.solana.com",
        network: .mainnetBeta
    )

    /// Transaction success with returned signature
    func testSendTransactionSuccess() async throws {
        let mock = NetworkManagerMock(NetworkManagerMockJSON["sendTransactionSuccess"]!)
        let apiClient = JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)
        let result = try await apiClient.sendTransaction(transaction: "")
        XCTAssertNotNil(result)
        XCTAssertEqual(
            result,
            "296E1ou3V9rRVktzCqNpzbzcTZMxTnFJCK2pWRoxKVidRfQam1KLRv6ETbKtf2S4CW1MyRCbeVairQQ3QWTPMRmt"
        )
    }

    /// Transaction failed: Blockhash not found
    func testSendTransactionBlockhashNotFound() async throws {
        let mock = NetworkManagerMock(NetworkManagerMockJSON["sendTransactionBlockhashNotFound"]!)
        let apiClient = JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)

        do {
            _ = try await apiClient.sendTransaction(transaction: "")
        } catch {
            XCTAssertTrue(error.isEqualTo(.blockhashNotFound))
        }
    }

    /// Transaction failed: whirpool InvalidTimestamp
    func testSendTransactionWhirpoolInvalidTimestamp() async throws {
        let mock = NetworkManagerMock(NetworkManagerMockJSON["sendTransactionWhirpoolInvalidTimestamp"]!)
        let apiClient = JSONRPCAPIClient(endpoint: endpoint, networkManager: mock)

        do {
            _ = try await apiClient.sendTransaction(transaction: "")
        } catch let APIClientError.responseError(response) {
            XCTAssertTrue(response.message!.hasSuffix("custom program error: 0x1786"))
        }
    }
}

private var NetworkManagerMockJSON = [
    // success
    "sendTransactionSuccess": #"{"jsonrpc":"2.0","result":"296E1ou3V9rRVktzCqNpzbzcTZMxTnFJCK2pWRoxKVidRfQam1KLRv6ETbKtf2S4CW1MyRCbeVairQQ3QWTPMRmt","id":"3FF1AACE-812A-4106-8C34-6EF66237673C"}"#,
    // blockhash not found
    "sendTransactionBlockhashNotFound":
        #"{"jsonrpc":"2.0","error":{"code":-32002,"message":"Transaction simulation failed: Blockhash not found","data":{"accounts":null,"err":"BlockhashNotFound","logs":[],"returnData":null,"unitsConsumed":0}},"id":"9E312DD6-EF0C-4A03-B7A4-CA3AAEB4407A"}"#,
    // whirpool InvalidTimestamp
    "sendTransactionWhirpoolInvalidTimestamp": #"{"jsonrpc":"2.0","error":{"code":-32002,"message":"Transaction simulation failed: Error processing Instruction 2: custom program error: 0x1786","data":{"accounts":null,"err":{"InstructionError":[2,{"Custom":6022}]},"logs":["Program JUP4Fb2cqiRUcaTHdrPC8h2gNsA2ETXiPDD33WcGuJB failed: custom program error: 0x1786"],"unitsConsumed":20724}},"id":"06BAEEB7-B99D-46B4-B19A-B05E80927A42"}"#,
]
