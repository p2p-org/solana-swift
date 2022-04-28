import Foundation

public protocol SolanaBasicProgramType {
    /// id of program on blockchain
    var id: PublicKey { get }
}
