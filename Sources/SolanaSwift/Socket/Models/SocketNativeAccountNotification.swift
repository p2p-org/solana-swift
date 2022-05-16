import Foundation

public typealias SocketNativeAccountNotification = Response<BufferInfo<EmptyInfo>> // TODO: - Fix later

extension SocketNativeAccountNotification {
    var lamports: Lamports? {
        params?.result?.value.lamports
    }
}
