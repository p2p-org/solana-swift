import Foundation

enum SocketError: Swift.Error {
    case subscriptionIdNotFound
    case accountResponseError(SocketObservableAccount)
    case signatureResponseError(SocketObservableSignature)
    
    static func responseError<Item: SubscriptionStorageItem>(_ item: Item) -> Self {
        switch item {
        case let item as SocketObservableSignature:
            return .signatureResponseError(item)
        case let item as SocketObservableAccount:
            return .accountResponseError(item)
        default:
            fatalError()
        }
    }
    
    func getResponseError<Item: SubscriptionStorageItem>(forObservingItem item: Item) -> Self? {
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
