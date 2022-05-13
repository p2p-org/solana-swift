import Foundation
import LoggerSwift

extension Socket {
    func subscribe(method: SocketMethod, params: [Encodable], account: String) async throws {
        let requestId = try await write(method: method, params: params)
        
        try Task.checkCancellation()
        var subscriptionId: UInt64?
        
        for try await result in self.subscribingResultsStream where requestId == result.requestId {
            subscriptionId = result.subscriptionId
            break
        }
        
        guard let subscriptionId = subscriptionId else {
            throw SolanaError.other("Subscription id not found")
        }

        await self.subscriptionsStorage.insertSubscription(
            .init(
                entity: .account,
                id: subscriptionId,
                account: account
            )
        )
    }
    
    /// Write message to socket
    /// - Parameters:
    ///   - method: method to write
    ///   - params: additional params
    /// - Returns: id of the subscription
    @discardableResult func write(method: SocketMethod, params: [Encodable]) async throws -> String {
        let requestAPI = RequestAPI(
            method: method.rawValue,
            params: params
        )
        
        let data = try JSONEncoder().encode(requestAPI)
        guard let string = String(data: data, encoding: .utf8) else {
            throw SolanaError.other("Request is invalid \(requestAPI)")
        }
        Logger.log(event: .request, message: string)
        
        try await task.send(.data(data))
        return requestAPI.id
        
//        let message = try await task.receive()
//        
//        switch message {
//        case .string(let string):
//            
//            Logger.log(event: .event, message: string)
//            
//            guard let data = string.data(using: .utf8) else {
//                throw SolanaError.other("Invalid data returned from string")
//            }
//            
//            switch method.action {
//            case .subscribe:
//                guard let json = (try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves)) as? [String: Any],
//                      (json["id"] as? String) == id
//                    else {
//                    throw SolanaError.other("Invalid data returned from string")
//                }
//                return
//            case .unsubscribe:
//            }
//        case .data(let data):
//            break
//        @unknown default:
//            break
//        }
//        
//            .filter { data in
//                
//            }
//            .map { data in
//                guard let subscription = try JSONDecoder().decode(Response<UInt64>.self, from: data).result
//                else {
//                    throw SolanaError.other("Subscription is not valid")
//                }
//                return subscription
//            }
    }
}
