import Foundation

public typealias SocketTokenAccountNotification = Response<BufferInfoParsed<SocketTokenAccountNotificationData>>

public extension SocketTokenAccountNotification {
    var tokenAmount: TokenAmount? {
        params?.result?.value.data?.parsed.info.tokenAmount
    }
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
