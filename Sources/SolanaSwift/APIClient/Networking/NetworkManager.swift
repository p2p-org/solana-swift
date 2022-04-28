import Foundation

public protocol NetworkManager {
    func requestData(request: URLRequest) async throws -> Data
}

public class APIClientNetworkManager: NetworkManager {
    
    private let session: URLSession
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func requestData(request: URLRequest) async throws -> Data {
        let (data, _): (Data, URLResponse)
        if #available(iOS 15.0, *) {
            (data, _) = try await session.data(for: request)
        } else {
            (data, _) = try await session.data(from: request)
        }
        return data
    }
    
}
