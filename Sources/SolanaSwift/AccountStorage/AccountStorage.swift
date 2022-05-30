import Foundation

public protocol SolanaAccountStorage {
    var account: Account? { get }
    func save(_ account: Account) throws
}
