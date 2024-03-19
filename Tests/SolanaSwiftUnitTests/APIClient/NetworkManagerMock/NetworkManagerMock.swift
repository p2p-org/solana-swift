import Foundation
import SolanaSwift

class NetworkManagerMock: NetworkManager {
    private let json: String
    init(_ json: String) {
        self.json = json
    }

    func requestData(request _: URLRequest) async throws -> Data {
        let str = json.data(using: .utf8)!
        return str
    }
}

extension NetworkManagerMock {
    func requestData(request _: URLRequest, res: String) async throws -> Data {
        let str = res.data(using: .utf8)!
        return str
    }
}
