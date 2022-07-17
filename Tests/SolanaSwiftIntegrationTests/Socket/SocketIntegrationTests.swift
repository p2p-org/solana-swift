import Combine
import SolanaSwift
import XCTest

class SocketIntegrationTests: XCTestCase {
    var socket: Socket!

    override func setUpWithError() throws {
        socket = Socket(url: .init(string: "wss://api.mainnet-beta.solana.com")!)
    }

    override func tearDownWithError() throws {
        socket.disconnect()
        socket = nil
    }

    func testSocketEvents() async throws {
        let expectation = XCTestExpectation()
        let delegate = MockSocketDelegate()
        delegate.onConected = {
            Task {
                let _ = try await self.socket
                    .accountSubscribe(publickey: "9xkso5sXmSEaEME7KDD7EumvYKyYRBJJ1ArQopnCGZrA") // native address

                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    Task {
                        try await self.socket
                            .accountSubscribe(publickey: "2uTfDKywe5ZGqyztJ6KMEPrRTa9WD53ueviYoti8vdCX") // usdc address
                    }
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                    Task {
                        try await self.socket
                            .signatureSubscribe(
                                signature: "2ctrG8WQWvbawgwY9mr7dv8LXXj4bridpD6b4sEJu7gFgvkrSgd6APu2Xnp6vq4oKEkvoSq9W1QzpVi9gZRrM6WR"
                            ) // signature status
                    }
                }

//                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
//                    Task {
//                        try await self.socket.logsSubscribeAll()
//                    }
//                }
//
//                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4)) {
//                    Task {
//                        try await self.socket.programSubscribe(publickey: "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA") // token program
//                    }
//                }
            }
        }
        delegate.onSubscribed = { subscriptionId, id in
            Logger.log(event: "response", message: "subscriptionId: \(subscriptionId), id: \(id)")
        }
        delegate.onNativeAccountNotification = { notification in
            Logger.log(event: "response", message: "lamports: \(String(describing: notification.lamports))")
        }
        delegate.onTokenAccountNotification = { notification in
            Logger.log(event: "response", message: "\(notification)")
        }
        delegate.onSignatureNotification = { notification in
            Logger.log(event: "response", message: "\(notification)")
        }
        delegate.onLogsNotification = { notification in
            Logger.log(event: "response", message: "\(notification)")
        }
        delegate.onProgramNotification = { notification in
            Logger.log(event: "response", message: "\(notification)")
        }
        delegate.onDisconnected = {
            expectation.fulfill()
        }

        socket.delegate = delegate
        socket.connect()
        wait(for: [expectation], timeout: 2000.0)
    }
}

class MockSocketDelegate: SolanaSocketEventsDelegate {
    var onConected: (() -> Void)?
    var onDisconnected: (() -> Void)?
    var onNativeAccountNotification: ((SocketNativeAccountNotification) -> Void)?
    var onTokenAccountNotification: ((SocketTokenAccountNotification) -> Void)?
    var onSignatureNotification: ((SocketSignatureNotification) -> Void)?
    var onLogsNotification: ((SocketLogsNotification) -> Void)?
    var onProgramNotification: ((SocketProgramAccountNotification) -> Void)?
    var onSubscribed: ((UInt64, String) -> Void)?
    var onUnsubscribed: ((String) -> Void)?

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

    func disconnected(reason _: String, code _: Int) {
        onDisconnected?()
    }

    func error(error _: Error?) {}
}
