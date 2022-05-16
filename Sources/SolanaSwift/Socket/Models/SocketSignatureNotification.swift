import Foundation

public typealias SocketSignatureNotification = Response<SocketSignatureNotificationData>

public struct SocketSignatureNotificationData: Decodable {
    let err: ResponseError?
}
