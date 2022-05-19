import Foundation

public typealias SocketProgramAccountNotification = Response<ProgramAccount<EmptyInfo>> // TODO: - Fix later

extension SocketProgramAccountNotification {
    public var subscription: UInt64? {
        params?.subscription
    }
}
