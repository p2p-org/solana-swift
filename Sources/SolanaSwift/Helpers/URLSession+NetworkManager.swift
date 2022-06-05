import Foundation

extension URLSession: NetworkManager {
    public func requestData(request: URLRequest) async throws -> Data {
        let (data, _): (Data, URLResponse)
        (data, _) = try await self.data(for: request)
        return data
    }
}
