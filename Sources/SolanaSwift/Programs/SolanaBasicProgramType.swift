import Foundation

public protocol SolanaBasicProgramType {
    /// id of program on blockchain
    static var id: PublicKey { get }
}
