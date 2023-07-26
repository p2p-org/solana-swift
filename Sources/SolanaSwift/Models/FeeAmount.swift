import Foundation

public struct FeeAmount: Equatable, Hashable {
    public struct OtherFee: Equatable, Hashable {
        public init(amount: Double, unit: String) {
            self.amount = amount
            self.unit = unit
        }

        public var amount: Double
        public var unit: String
    }

    public init(transaction: UInt64, accountBalances: UInt64, deposit: UInt64 = 0, others: [OtherFee]? = nil) {
        self.transaction = transaction
        self.accountBalances = accountBalances
        self.others = others
        self.deposit = deposit
    }

    public var transaction: UInt64
    public var accountBalances: UInt64
    public var deposit: UInt64
    public var others: [OtherFee]?
    public var total: UInt64 {
        transaction + accountBalances + deposit
    }

    public static var zero: Self {
        .init(transaction: 0, accountBalances: 0)
    }
}

public extension FeeAmount {
    static func + (lhs: FeeAmount, rhs: FeeAmount) -> FeeAmount {
        return .init(
            transaction: lhs.transaction + rhs.transaction,
            accountBalances: lhs.accountBalances + rhs.accountBalances,
            deposit: lhs.deposit + rhs.deposit,
            others: lhs.others == nil && rhs.others == nil ? nil : ((lhs.others ?? []) + (rhs.others ?? []))
        )
    }
}
