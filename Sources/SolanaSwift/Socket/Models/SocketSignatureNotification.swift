import Foundation

public typealias SocketSignatureNotification = Response<SocketSignatureNotificationData>

public extension SocketSignatureNotification {
    var isConfirmed: Bool {
        params?.result?.value.err == nil
    }

    var error: ResponseError? {
        params?.result?.value.err
    }
}

public struct SocketSignatureNotificationData: Decodable {
    let err: ResponseError?
}
