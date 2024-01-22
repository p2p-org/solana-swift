import Foundation

public struct ParsedTransferFeeConfig: Codable {
    public static let name: String = "transferFeeConfig"

    public struct TransferFee: Codable {
        let epoch: Int64
        let maximumFee: Double
        let transferFeeBasisPoints: Int64
    }

    public let newerTransferFee, olderTransferFee: TransferFee
    public let transferFeeConfigAuthority, withdrawWithheldAuthority: String
    public let withheldAmount: Int64
}
