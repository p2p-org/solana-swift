import Foundation

public class AccountInfoStream: AsyncSequence {
    public typealias Element = BufferInfo<AccountInfo>
    public typealias AsyncIterator = AsyncThrowingStream<BufferInfo<AccountInfo>, Error>.Iterator
    
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
    
    public func makeAsyncIterator() -> AsyncIterator {
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
                continuation?.yield(message) // TODO: Convert message to BufferInfo<AccountInfo>
                listenForMessages()
            case .failure(let error):
                continuation?.finish(throwing: error)
            }
        }
    }
}
