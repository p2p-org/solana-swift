import XCTest
import SolanaSwift

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
    private let pointer = 0
    
    func resume() {
        
    }
    
    func cancel() {
        
    }
    
    func send(_ message: URLSessionWebSocketTask.Message) async throws {
        <#code#>
    }
    
    func receive() async throws -> URLSessionWebSocketTask.Message {
        <#code#>
    }
    
    func sendPing(pongReceiveHandler: @escaping (Error?) -> Void) {
        <#code#>
    }
}
