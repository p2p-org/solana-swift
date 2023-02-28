import Foundation

public protocol SolanaAccountStorage {
    var account: KeyPair? { get }
    func save(_ account: KeyPair) throws
}
