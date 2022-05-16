import Foundation

public typealias SocketNativeAccountNotification = Response<BufferInfo<EmptyInfo>> // TODO: - Fix later

extension SocketNativeAccountNotification {
    public var lamports: Lamports? {
        params?.result?.value.lamports
    }
}
