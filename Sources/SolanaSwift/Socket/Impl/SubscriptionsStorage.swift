import Foundation

actor SubscriptionsStorage {
    var observingAccounts = Set<SocketObservableAccount>()
    var activeAccountSubscriptions = [SocketSubscription]()
    
    func subscriptionExists(account: SocketObservableAccount) -> Bool {
        activeAccountSubscriptions.contains(where: {$0.account == account.pubkey})
    }
    
    func insertObservableAccount(_ account: SocketObservableAccount) {
        observingAccounts.insert(account)
    }
}
