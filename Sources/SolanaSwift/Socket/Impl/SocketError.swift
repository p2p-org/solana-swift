import Foundation

enum SocketError: Swift.Error {
    case subscriptionIdNotFound
    case accountResponseError(SocketObservableAccount)
}
