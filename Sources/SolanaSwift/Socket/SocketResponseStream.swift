import Foundation

public class SocketResponseStream<Element: Decodable>: AsyncSequence {
    public typealias AsyncIterator = AsyncThrowingStream<Element, Error>.Iterator
    
    private var stream: AsyncThrowingStream<Element, Error>?
    private var continuation: AsyncThrowingStream<Element, Error>.Continuation?
    
    private(set) var onReceiving: ((Element) -> Void)?
    private(set) var onFailure: ((Error) -> Void)?
    
    init() {
        self.stream = AsyncThrowingStream { continuation in
            self.continuation = continuation
        }
        
        self.onReceiving = { [weak self] info in
            self?.continuation?.yield(info)
        }
        
        self.onFailure = { [weak self] error in
            self?.continuation?.finish(throwing: error)
        }
    }
    
    public func makeAsyncIterator() -> AsyncIterator {
        guard let stream = stream else {
            fatalError("stream was not initialized")
        }
        return stream.makeAsyncIterator()
    }
}
