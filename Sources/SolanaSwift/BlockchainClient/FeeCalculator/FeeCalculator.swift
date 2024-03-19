import Foundation

public protocol FeeCalculator: AnyObject {
    func calculateNetworkFee(transaction: Transaction) throws -> FeeAmount
}

public class DefaultFeeCalculator: FeeCalculator {
    private let lamportsPerSignature: Lamports
    private let minRentExemption: Lamports

    public init(lamportsPerSignature: Lamports, minRentExemption: Lamports) {
        self.lamportsPerSignature = lamportsPerSignature
        self.minRentExemption = minRentExemption
    }

    public func calculateNetworkFee(transaction: Transaction) throws -> FeeAmount {
        let transactionFee = try transaction.calculateTransactionFee(lamportsPerSignatures: lamportsPerSignature)
        var accountCreationFee: Lamports = 0
        var depositFee: Lamports = 0
        for instruction in transaction.instructions {
            var createdAccount: PublicKey?
            switch instruction.programId {
            case SystemProgram.id:
                guard instruction.data.count >= 4 else { break }
                let index = UInt32(bytes: instruction.data[0 ..< 4])
                if index == SystemProgram.Index.create {
                    createdAccount = instruction.keys.last?.publicKey
                }
            case AssociatedTokenProgram.id:
                createdAccount = instruction.keys[safe: 1]?.publicKey
            default:
                break
            }

            if let createdAccount = createdAccount {
                // Check if account is closed right after its creation
                let closingInstruction = transaction.instructions.first(
                    where: {
                        $0.data.first == TokenProgram.closeAccountIndex &&
                            $0.keys.first?.publicKey == createdAccount
                    }
                )
                let isAccountClosedAfterCreation = closingInstruction != nil

                // If account is closed after creation, increase the deposit fee
                if isAccountClosedAfterCreation {
                    depositFee += minRentExemption
                }

                // Otherwise, there will be an account creation fee
                else {
                    accountCreationFee += minRentExemption
                }
            }
        }

        return .init(transaction: transactionFee, accountBalances: accountCreationFee, deposit: depositFee)
    }
}
