import Foundation

public struct ParsedTransferFeeConfig: Codable {
    static let name: String = "transferFeeConfig"
    
    public struct TransferFee: Codable {
        let epoch: Int
        let maximumFee: Double
        let transferFeeBasisPoints: Int
    }
    
    let newerTransferFee, olderTransferFee: TransferFee
    let transferFeeConfigAuthority, withdrawWithheldAuthority: String
    let withheldAmount: Int
}
