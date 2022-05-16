import Foundation

public enum SocketMethod: String {
    case accountNotification
    case accountSubscribe
    case accountUnsubscribe

    case signatureNotification
    case signatureSubscribe
    case signatureUnsubscribe

    case logsSubscribe
    case logsNotification
    case logsUnsubscribe

    case programSubscribe
    case programNotification
    case programUnsubscribe

    case slotSubscribe
    case slotNotification
    case slotUnsubscribe
}

struct SocketSubscription: Decodable {
    let jsonrpc: String
    let id: String
    let result: UInt64
}

public struct SocketSignatureNotification: Decodable {
    let err: ResponseError?
}

public struct SocketLogsNotification: Decodable {
    let signature: String
    let logs: [String]
    let err: ResponseError?
}
