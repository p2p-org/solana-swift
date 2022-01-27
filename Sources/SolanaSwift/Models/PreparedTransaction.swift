import Foundation

extension SolanaSDK {
    public struct PreparedTransaction {
        public init(transaction: SolanaSDK.Transaction, signers: [SolanaSDK.Account], expectedFee: FeeAmount) {
            self.transaction = transaction
            self.signers = signers
            self.expectedFee = expectedFee
        }
        
        public var transaction: Transaction
        public var signers: [Account]
        public var expectedFee: FeeAmount
        
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
        
        public func findSignature(publicKey: PublicKey) throws -> String {
            guard let signature = transaction.findSignature(pubkey: publicKey)?.signature
            else {
                throw Error.other("Signature not found")
            }
            return Base58.encode(signature.bytes)
        }
    }
}
