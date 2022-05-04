import Foundation

protocol SolanaAccountStorage: AnyObject {
    var account: Account? {get throws}
    func save(_ account: Account) throws
}
