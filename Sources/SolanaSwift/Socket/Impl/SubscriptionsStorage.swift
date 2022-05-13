import Foundation

actor SubscriptionsStorage {
    var observingAccounts = Set<SocketObservableAccount>()
    var activeAccountSubscriptions = Set<SocketSubscription>()
    
    func subscriptionExists(account: SocketObservableAccount) -> Bool {
        activeAccountSubscriptions.contains(where: {$0.account == account.pubkey})
    }
    
    func insertObservableAccount(_ account: SocketObservableAccount) {
        observingAccounts.insert(account)
    }
    
    func insertSubscription(_ subscription: SocketSubscription) {
        activeAccountSubscriptions.insert(subscription)
    }
}
