import Foundation

extension URLSession: NetworkManager {
    
    public func requestData(request: URLRequest) async throws -> Data {
        let (data, _): (Data, URLResponse)
        if #available(iOS 15.0, macOS 12.0, *) {
            (data, _) = try await self.data(for: request)
        } else {
            (data, _) = try await self.data(from: request)
        }
        return data
    }
}
