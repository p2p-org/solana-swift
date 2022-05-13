import Foundation

enum SocketError: Swift.Error, Equatable {
    case subscriptionFailed(id: String) // failed to get subscription id from socket
    
    case subscriptionIdNotFound
    case accountResponseError(SocketObservableAccount)
    case signatureResponseError(SocketObservableSignature)
    
    static func responseError<Item: SocketObservableItem>(_ item: Item) -> Self {
        switch item {
        case let item as SocketObservableSignature:
            return .signatureResponseError(item)
        case let item as SocketObservableAccount:
            return .accountResponseError(item)
        default:
            fatalError()
        }
    }
    
    func getResponseError<Item: SocketObservableItem>(forObservingItem item: Item) -> Self? {
        switch self {
        case .accountResponseError(let socketObservableAccount):
            if let item = item as? SocketObservableAccount, item == socketObservableAccount {
                return self
            }
        case .signatureResponseError(let socketObservableSignature):
            if let item = item as? SocketObservableSignature, item == socketObservableSignature {
                return self
            }
        default:
            break
        }
        return nil
    }
}
