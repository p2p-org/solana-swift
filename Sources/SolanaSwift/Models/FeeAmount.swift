import Foundation

extension SolanaSDK {
    public struct FeeAmount: Equatable {
        public init(transaction: UInt64, accountBalances: UInt64) {
            self.transaction = transaction
            self.accountBalances = accountBalances
        }
        
        public var transaction: UInt64
        public var accountBalances: UInt64
        public var total: UInt64 {
            transaction + accountBalances
        }
    }
}
