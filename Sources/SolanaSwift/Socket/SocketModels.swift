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

public enum SocketError: Error {
    case disconnected
    case couldNotSerialize
}

struct SocketSubscription: Decodable {
    let jsonrpc: String
    let id: String
    let result: UInt64
}

public struct SocketTokenAccountNotificationData: Decodable {
    public let program: String
    public let parsed: SocketTokenAccountNotificationDataParsed
}

public struct SocketTokenAccountNotificationDataParsed: Decodable {
    public let type: String
    public let info: SocketTokenAccountNotificationDataInfo
}

public struct SocketTokenAccountNotificationDataInfo: Decodable {
    public let tokenAmount: TokenAmount
}

public struct SocketSignatureNotification: Decodable {
    let err: ResponseError?
}

public struct SocketLogsNotification: Decodable {
    let signature: String
    let logs: [String]
    let err: ResponseError?
}
