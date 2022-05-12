import Foundation

class WebSocketStream: AsyncSequence {
    typealias Element = URLSessionWebSocketTask.Message
    typealias AsyncIterator = AsyncThrowingStream<URLSessionWebSocketTask.Message, Error>.Iterator
    
    private var stream: AsyncThrowingStream<Element, Error>?
    private var continuation: AsyncThrowingStream<Element, Error>.Continuation?
    private let task: URLSessionWebSocketTask
    
    init(tast: URLSessionWebSocketTask) {
        self.task = tast
        self.stream = AsyncThrowingStream { continuation in
            self.continuation = continuation
//            self.continuation?.onTermination = { @Sendable [task] _ in
//                task.cancel()
//            }
        }
    }
    
    func makeAsyncIterator() -> AsyncIterator {
        guard let stream = stream else {
            fatalError("stream was not initialized")
        }
//        task.resume()
        listenForMessages()
        return stream.makeAsyncIterator()
    }
    
    private func listenForMessages() {
        task.receive { [unowned self] result in
            switch result {
            case .success(let message):
                continuation?.yield(message)
                listenForMessages()
            case .failure(let error):
                continuation?.finish(throwing: error)
            }
        }
    }
}
