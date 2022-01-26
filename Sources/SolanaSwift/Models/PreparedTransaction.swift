import Foundation

extension SolanaSDK {
    public struct PreparedTransaction {
        public init(transaction: SolanaSDK.Transaction, signers: [SolanaSDK.Account]) {
            self.transaction = transaction
            self.signers = signers
        }
        
        public var transaction: Transaction
        public var signers: [Account]
        
        public func serialize() throws -> String {
            var transaction = transaction
            let serializedTransaction = try transaction.serialize().bytes.toBase64()
            #if DEBUG
            Logger.log(message: serializedTransaction, event: .info)
            if let decodedTransaction = transaction.jsonString {
                Logger.log(message: decodedTransaction, event: .info)
            }
            #endif
            return serializedTransaction
        }
    }
}
