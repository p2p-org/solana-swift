import XCTest
import SolanaSwift
import Combine

class SocketTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

private class MockSocketTaskProvider: WebSocketTaskProvider {
    let delegate: URLSessionWebSocketDelegate?
    let mockSession = URLSession(configuration: .default)
    private lazy var mockWSTask = mockSession.webSocketTask(with: .init(string: "wss://api.mainnet-beta.solana.com")!)
    
    required init(configuration: URLSessionConfiguration, delegate: URLSessionDelegate?, delegateQueue queue: OperationQueue?) {
        self.delegate = delegate as? URLSessionWebSocketDelegate
        self.delegate?.urlSession?(.shared, webSocketTask: mockWSTask, didOpenWithProtocol: nil)
    }
    
    func createWebSocketTask(with url: URL) -> WebSocketTask {
        MockSocketTask()
    }
    
    
}

private class MockSocketTask: WebSocketTask {
    private var continuation: CheckedContinuation<String, Error>!
    private var nativeEmitted: Bool = false
    
    func resume() {
        // do nothing
    }
    
    func cancel() {
        // do nothing
    }
    
    func send(_ message: URLSessionWebSocketTask.Message) async throws {
        struct RequestAPI: Decodable {
            let id: String
            let method: String
            let jsonrpc: String
            let params: [String]
        }
        
        switch message {
        case .string:
            break
        case .data(let data):
            let requestAPI = try JSONDecoder().decode(RequestAPI.self, from: data)
            let method = SocketMethod(rawValue: requestAPI.method)!
            switch method {
            case .accountNotification:
                continuation.resume(returning: "accountNotification#\(nativeEmitted ? "Token": "Native")")
                nativeEmitted = true
            case .accountSubscribe:
                continuation.resume(returning: "subscriptionNotification")
            case .accountUnsubscribe:
                continuation.resume(returning: "unsubscriptionNotification")
            case .signatureSubscribe:
                continuation.resume(returning: "subscriptionNotification")
            case .signatureUnsubscribe:
                continuation.resume(returning: "unsubscriptionNotification")
            case .logsSubscribe:
                continuation.resume(returning: "subscriptionNotification")
            case .logsUnsubscribe:
                continuation.resume(returning: "unsubscriptionNotification")
            case .programSubscribe:
                continuation.resume(returning: "subscriptionNotification")
            case .programUnsubscribe:
                continuation.resume(returning: "unsubscriptionNotification")
            case .slotSubscribe:
                continuation.resume(returning: "subscriptionNotification")
            case .slotUnsubscribe:
                continuation.resume(returning: "unsubscriptionNotification")
            default:
                continuation.resume(returning: method.rawValue)
            }
            break
        @unknown default:
            fatalError()
        }
    }
    
    func receive() async throws -> URLSessionWebSocketTask.Message {
        let key = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
            self.continuation = continuation
        }
        return .string(SocketTestsHelper.emittingEvents[key]!)
    }
    
    func sendPing(pongReceiveHandler: @escaping (Error?) -> Void) {
        debugPrint("Pong!!!")
    }
}
