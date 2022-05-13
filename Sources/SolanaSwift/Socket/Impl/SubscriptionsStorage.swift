import Foundation

struct SubscriptionsStorages {
    let accountSubscriptionsStorage = SubscriptionsStorage<SocketObservableAccount>()
    let signatureSubscriptionsStorage = SubscriptionsStorage<SocketObservableSignature>()
    
    let accountInfoStream = SocketResponseStream<Result<SocketObservableAccount, Error>>()
    let signatureInfoStream = SocketResponseStream<Result<SocketObservableSignature, Error>>()
    
    func onFinish() {
        accountInfoStream.onFinish?()
        signatureInfoStream.onFinish?()
    }
    
    func isSubscriptionExists<Item: SubscriptionStorageItem>(item: Item) async -> Bool {
        switch item {
        case let item as SocketObservableAccount:
            return await accountSubscriptionsStorage.activeSubscriptions.contains(where: {item.pubkey == $0.item.pubkey})
        case let item as SocketObservableSignature:
            return await signatureSubscriptionsStorage.activeSubscriptions.contains(where: {item == $0.item})
        default:
            fatalError()
        }
    }
    
    func insertObservableItem<Item: SubscriptionStorageItem>(_ item: Item) async {
        switch item {
        case let item as SocketObservableAccount:
            await accountSubscriptionsStorage.insertObservingItem(item)
        case let item as SocketObservableSignature:
            await signatureSubscriptionsStorage.insertObservingItem(item)
        default:
            fatalError()
        }
    }
    
    func insertSubscription<Item: SubscriptionStorageItem>(_ subscription: SocketSubscription<Item>) async {
        switch subscription {
        case let subscription as SocketSubscription<SocketObservableAccount>:
            await accountSubscriptionsStorage.insertSubscription(subscription)
        case let subscription as SocketSubscription<SocketObservableSignature>:
            await signatureSubscriptionsStorage.insertSubscription(subscription)
        default:
            fatalError()
        }
    }
}

protocol SubscriptionStorageItem: Hashable {}
extension SocketObservableSignature: SubscriptionStorageItem {}
extension SocketObservableAccount: SubscriptionStorageItem {}

actor SubscriptionsStorage<Item: SubscriptionStorageItem> {
    var observingItems = Set<Item>()
    var activeSubscriptions = Set<SocketSubscription<Item>>()
    
    func insertObservingItem(_ item: Item) {
        observingItems.insert(item)
    }
    
    func insertSubscription(_ subscription: SocketSubscription<Item>) {
        activeSubscriptions.insert(subscription)
    }
}
