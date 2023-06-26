import Foundation

public enum Network: String, CaseIterable, Codable {
    case mainnetBeta = "mainnet-beta"
    case devnet
    case testnet

    public var cluster: String { rawValue }

    public var isTestnet: Bool {
        self != .mainnetBeta
    }
}
