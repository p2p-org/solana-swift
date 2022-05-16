import Foundation

public typealias SocketLogsNotification = Response<SocketLogsNotificationData>

public struct SocketLogsNotificationData: Decodable {
    let signature: String
    let logs: [String]
    let err: ResponseError?
}
