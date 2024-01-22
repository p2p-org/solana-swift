import Foundation

public struct ParsedTransferFeeConfig: Codable {
    public static let name: String = "transferFeeConfig"

    public struct TransferFee: Codable {
        public let epoch: UInt64
        public let maximumFee: UInt64
        public let transferFeeBasisPoints: UInt64
    }

    public let newerTransferFee, olderTransferFee: TransferFee
    public let transferFeeConfigAuthority, withdrawWithheldAuthority: String
    public let withheldAmount: UInt64
}
