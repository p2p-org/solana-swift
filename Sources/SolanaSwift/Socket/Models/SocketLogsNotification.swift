import Foundation

public typealias SocketLogsNotification = Response<SocketLogsNotificationData>

public extension SocketLogsNotification {
    var logs: [String]? {
        params?.result?.value.logs
    }

    var signature: String? {
        params?.result?.value.signature
    }
}

public struct SocketLogsNotificationData: Decodable {
    let signature: String
    let logs: [String]
    let err: ResponseError?
}
