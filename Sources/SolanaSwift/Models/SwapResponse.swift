import Foundation

public struct SwapResponse {
    public let transactionId: String
    public let newWalletPubkey: String?

    public init(transactionId: String, newWalletPubkey: String?) {
        self.transactionId = transactionId
        self.newWalletPubkey = newWalletPubkey
    }
}
