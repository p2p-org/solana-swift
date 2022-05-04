import Foundation

public protocol SolanaBasicProgram {
    /// id of program on blockchain
    var id: PublicKey { get }
}
