import Foundation

public protocol NetworkManager {
    func requestData(request: URLRequest) async throws -> Data
}
