import Foundation

public protocol SolanaBasicProgram {
    /// id of program on blockchain
    static var id: PublicKey { get }
}
