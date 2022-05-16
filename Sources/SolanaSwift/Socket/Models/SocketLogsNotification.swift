import Foundation

public typealias SocketLogsNotification = Response<SocketLogsNotificationData>

extension SocketLogsNotification {
    public var logs: [String]? {
        params?.result?.value.logs
    }
    public var signature: String? {
        params?.result?.value.signature
    }
}

public struct SocketLogsNotificationData: Decodable {
    let signature: String
    let logs: [String]
    let err: ResponseError?
}
