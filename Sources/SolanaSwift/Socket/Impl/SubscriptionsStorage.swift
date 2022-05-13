import Foundation

actor SubscriptionsStorage {
    var observingAccounts = Set<SocketObservableAccount>()
    var activeAccountSubscriptions = Set<SocketSubscription>()
    
    func subscriptionExists(account: String) -> Bool {
        activeAccountSubscriptions.contains(where: {$0.account == account})
    }
    
    func insertObservableAccount(_ account: SocketObservableAccount) {
        observingAccounts.insert(account)
    }
    
    func removeObservingAccount(_ account: String) {
        guard let observingAccount = observingAccounts.first(where: {$0.pubkey == account})
        else { return }
        observingAccounts.remove(observingAccount)
    }
    
    func insertSubscription(_ subscription: SocketSubscription) {
        activeAccountSubscriptions.insert(subscription)
    }
    
    func cancelSubscription(_ subscription: SocketSubscription) {
        activeAccountSubscriptions.remove(subscription)
    }
    
    func cancelAllSubscriptions() {
        activeAccountSubscriptions = []
    }
}
