import Foundation

public protocol SolanaAccountStorage {
    var account: Account? { get throws }
    func save(_ account: Account) throws
}
