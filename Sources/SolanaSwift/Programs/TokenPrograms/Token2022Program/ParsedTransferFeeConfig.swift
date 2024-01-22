import Foundation

public struct ParsedTransferFeeConfig: Codable {
    public static let name: String = "transferFeeConfig"

    public struct TransferFee: Codable {
        let epoch: UInt64
        let maximumFee: UInt64
        let transferFeeBasisPoints: UInt64
    }

    public let newerTransferFee, olderTransferFee: TransferFee
    public let transferFeeConfigAuthority, withdrawWithheldAuthority: String
    public let withheldAmount: UInt64
}
