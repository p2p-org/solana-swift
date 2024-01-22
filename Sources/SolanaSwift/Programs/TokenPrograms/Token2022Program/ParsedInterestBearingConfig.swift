import Foundation

public struct ParsedInterestBearingConfig: Codable {
    public static let name: String = "interestBearingConfig"
    
    public let currentRate: Int64
    public let preUpdateAverageRate: UInt64
    public let initializationTimestamp: UInt64
    public let lastUpdateTimestamp: UInt64
    public let rateAuthority: PublicKey
}


