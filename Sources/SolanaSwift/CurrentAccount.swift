import Foundation

@available(*, deprecated, renamed: "CurrentAccount")
public typealias SolanaAccountStorage = CurrentKeyPair

public protocol CurrentKeyPair {
    @available(*, deprecated, renamed: "value")
    var account: KeyPair? { get }

    var value: KeyPair? { get }
}

extension CurrentKeyPair {
    var account: KeyPair? { value }
}
