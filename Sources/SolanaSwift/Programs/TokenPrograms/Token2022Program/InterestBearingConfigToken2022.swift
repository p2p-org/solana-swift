import Foundation

public struct ParsedInterestBearingConfig: Codable {
    static let name: String = "interestBearingConfig"
    
    public let currentRate: Int64
    public let preUpdateAverageRate: Int64
    public let initializationTimestamp: Int64
    public let lastUpdateTimestamp: Int64
    public let rateAuthority: PublicKey
}


