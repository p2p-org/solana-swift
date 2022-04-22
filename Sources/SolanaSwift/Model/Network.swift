import Foundation

public extension SolanaSDK_Deprecated {
    public typealias Network = SolanaSwift.Network
}

public enum Network: String, CaseIterable, Codable {
    case mainnetBeta = "mainnet-beta"
    case devnet = "devnet"
    case testnet = "testnet"
    
    public var cluster: String {rawValue}
    
    public var isTestnet: Bool {
        self != .mainnetBeta
    }
}
