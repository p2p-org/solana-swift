import SolanaSwift
import XCTest

class SocketDecodingTests: XCTestCase {
    func testDecodingSocketSubscription() throws {
        let string = SocketTestsHelper.emittingEvents["subscriptionNotification"]!
        let result = try JSONDecoder().decode(SocketSubscriptionResponse.self, from: string.data(using: .utf8)!)

        XCTAssertEqual(result.id, "ADFB8971-4473-4B16-A8BC-63EFD2F1FC8E")
        XCTAssertEqual(result.result, 22_529_999)
    }

    func testDecodingSocketUnsubscription() throws {
        let string = SocketTestsHelper.emittingEvents["unsubscriptionNotification"]!
        let result = try JSONDecoder().decode(SocketUnsubscriptionResponse.self, from: string.data(using: .utf8)!)

        XCTAssertEqual(result.id, "ADFB8971-4473-4B16-A8BC-63EFD2F1FC8E")
        XCTAssertEqual(result.result, true)
    }

    func testDecodingSOLAccountNotification() throws {
        let string = SocketTestsHelper.emittingEvents["accountNotification#Native"]!
        let result = try JSONDecoder().decode(SocketNativeAccountNotification.self, from: string.data(using: .utf8)!)

        XCTAssertEqual(result.method, "accountNotification")
        XCTAssertEqual(result.lamports, 41_083_620)
    }

    func testDecodingProgramNotification() throws {
        let string = SocketTestsHelper.emittingEvents["programNotification"]!
        let result = try JSONDecoder().decode(SocketProgramAccountNotification.self, from: string.data(using: .utf8)!)

        XCTAssertEqual(result.method, "programNotification")
        XCTAssertEqual(result.subscription, 24040)
    }

    func testDecodingTokenAccountNotification() throws {
        let string = SocketTestsHelper.emittingEvents["accountNotification#Token"]!
        let result = try JSONDecoder().decode(SocketTokenAccountNotification.self, from: string.data(using: .utf8)!)

        XCTAssertEqual(result.method, "accountNotification")
        XCTAssertEqual(result.tokenAmount?.amount, "390000101")
    }

    func testDecodingSignatureNotification() throws {
        let string = SocketTestsHelper.emittingEvents["signatureNotification"]!
        let result = try JSONDecoder().decode(SocketSignatureNotification.self, from: string.data(using: .utf8)!)

        XCTAssertEqual(result.method, "signatureNotification")
        XCTAssertEqual(result.isConfirmed, true)
    }

    func testDecodingLogsNotification() throws {
        let string = SocketTestsHelper.emittingEvents["logsNotification"]!
        let result = try JSONDecoder().decode(SocketLogsNotification.self, from: string.data(using: .utf8)!)

        XCTAssertEqual(result.method, "logsNotification")
        XCTAssertEqual(result.logs?.first, "BPF program 83astBRguLMdt2h5U1Tpdq5tjFoJ6noeGwaY3mDLVcri success")
    }
}
