import XCTest
import SolanaSwift
import Combine

class SocketTests: XCTestCase {
    var socket: SolanaSocket!
    
    override func setUpWithError() throws {
        socket = SolanaSocket(url: SocketTestsHelper.url, enableDebugLogs: true, socketTaskProviderType: MockSocketTaskProvider.self)
    }

    override func tearDownWithError() throws {
        socket.disconnect()
        socket = nil
    }

    func testSocketConnected() async throws {
        let expectation = XCTestExpectation()
        let delegate = MockSolanaLiveEventsDelegate()
        delegate.onConected = {
            expectation.fulfill()
        }
        socket.delegate = delegate
        socket.connect()
        wait(for: [expectation], timeout: 20.0)
    }
    
    func testSocketSubscribe() {
        let expectation = XCTestExpectation()
        let delegate = MockSolanaLiveEventsDelegate()
        delegate.onConected = {
            Task {
                try await self.socket.accountSubscribe(publickey: "fasdfasdf")
            }
        }
        delegate.onSubscribed = { (subscriptionId, id) in
            expectation.fulfill()
            XCTAssertEqual("ADFB8971-4473-4B16-A8BC-63EFD2F1FC8E", id)
        }
        socket.delegate = delegate
        socket.connect()
        wait(for: [expectation], timeout: 20.0)
    }
}

private class MockSocketTaskProvider: WebSocketTaskProvider {
    let delegate: URLSessionWebSocketDelegate?
    let mockSession = URLSession(configuration: .default)
    private lazy var mockWSTask = mockSession.webSocketTask(with: SocketTestsHelper.url)
    
    required init(configuration: URLSessionConfiguration, delegate: URLSessionDelegate?, delegateQueue queue: OperationQueue?) {
        self.delegate = delegate as? URLSessionWebSocketDelegate
        
        // connect after 0.3 sec
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            self.delegate?.urlSession?(.shared, webSocketTask: self.mockWSTask, didOpenWithProtocol: nil)
        }
        
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

class MockSolanaLiveEventsDelegate: SolanaSocketEventsDelegate {
    
    var onConected: (() -> Void)? = nil
    var onDisconnected: (() -> Void)? = nil
    var onNativeAccountNotification: ((SocketNativeAccountNotification) -> Void)? = nil
    var onTokenAccountNotification: ((SocketTokenAccountNotification) -> Void)? = nil
    var onSignatureNotification: ((SocketSignatureNotification) -> Void)? = nil
    var onLogsNotification: ((SocketLogsNotification) -> Void)? = nil
    var onProgramNotification: ((SocketProgramAccountNotification) -> Void)? = nil
    var onSubscribed: ((UInt64, String) -> Void)? = nil
    var onUnsubscribed: ((String) -> Void)? = nil

    func connected() {
        onConected?()
    }
    
    
    func nativeAccountNotification(notification: SocketNativeAccountNotification) {
        onNativeAccountNotification?(notification)
    }
    
    func tokenAccountNotification(notification: SocketTokenAccountNotification) {
        onTokenAccountNotification?(notification)
    }
    
    func signatureNotification(notification: SocketSignatureNotification) {
        onSignatureNotification?(notification)
    }
    
    func logsNotification(notification: SocketLogsNotification) {
        onLogsNotification?(notification)
    }
    
    func programNotification(notification: SocketProgramAccountNotification) {
        onProgramNotification?(notification)
    }
    
    func subscribed(socketId: UInt64, id: String) {
        onSubscribed?(socketId, id)
    }
    
    func unsubscribed(id: String) {
        onUnsubscribed?(id)
    }
    
    func disconnected(reason: String, code: Int) {
        onDisconnected?()
    }
    
    func error(error: Error?) {
        
    }
}
