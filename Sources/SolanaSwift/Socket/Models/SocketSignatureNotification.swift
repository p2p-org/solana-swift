import Foundation

public typealias SocketSignatureNotification = Response<SocketSignatureNotificationData>

extension SocketSignatureNotification {
    public var isConfirmed: Bool {
        params?.result?.value.err == nil
    }
    public var error: ResponseError? {
        params?.result?.value.err
    }
}

public struct SocketSignatureNotificationData: Decodable {
    let err: ResponseError?
}
