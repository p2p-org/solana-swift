import Foundation

public typealias SocketProgramAccountNotification = Response<ProgramAccount<EmptyInfo>> // TODO: - Fix later

public extension SocketProgramAccountNotification {
    var subscription: UInt64? {
        params?.subscription
    }
}
