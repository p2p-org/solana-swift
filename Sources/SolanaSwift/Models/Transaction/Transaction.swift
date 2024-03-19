import Foundation
import TweetNacl

public struct Transaction: Encodable, Equatable {
    public var signatures = [Signature]()
    public var feePayer: PublicKey?
    public var instructions = [TransactionInstruction]()
    public var recentBlockhash: String?
//        TODO: nonceInfo

    public init() {}
    public init(
        instructions: [TransactionInstruction],
        recentBlockhash: String? = nil,
        feePayer: PublicKey? = nil
    ) {
        self.init()
        self.instructions = instructions
        self.recentBlockhash = recentBlockhash
        self.feePayer = feePayer
    }

    // MARK: - Methods

    public mutating func sign(signers: [KeyPair]) throws {
        guard !signers.isEmpty else {
            throw VersionedTransactionError.noSigner
        }

        // unique signers
        let signers = signers.reduce([KeyPair]()) { signers, signer in
            var uniqueSigners = signers
            if !uniqueSigners.contains(where: { $0.publicKey == signer.publicKey }) {
                uniqueSigners.append(signer)
            }
            return uniqueSigners
        }

        // map signatures
        signatures = signers.map { Signature(signature: nil, publicKey: $0.publicKey) }

        // construct message
        let message = try compile()

        try partialSign(message: message, signers: signers)
    }

    public func calculateTransactionFee(lamportsPerSignatures: UInt64) throws -> UInt64 {
        var transaction = self
        transaction.recentBlockhash = "BdA9gRatFvvwszr9uU5fznkHoMVQE8tf6ZFi8Mp6xdKs" // fake
        let message = try transaction.compile()
        return UInt64(message.header.numRequiredSignatures) * lamportsPerSignatures
    }

    public mutating func serialize(
        requiredAllSignatures: Bool = true,
        verifySignatures: Bool = false
    ) throws -> Data {
        // message
        let serializedMessage = try serializeMessage()

        // verification
        if verifySignatures, !_verifySignatures(
            serializedMessage: serializedMessage,
            requiredAllSignatures: requiredAllSignatures
        ) {
            throw VersionedTransactionError.signatureVerificationError
        }

        return _serialize(serializedMessage: serializedMessage)
    }

    // MARK: - Helpers

    public mutating func addSignature(_ signature: Signature) throws {
        let _ = try compile() // Ensure signatures array is populated

        try _addSignature(signature)
    }

    mutating func serializeMessage() throws -> Data {
        try compile().serialize()
    }

    mutating func verifySignatures() throws -> Bool {
        try _verifySignatures(serializedMessage: serializeMessage(), requiredAllSignatures: true)
    }

    public func findSignature(pubkey: PublicKey) -> Signature? {
        signatures.first(where: { $0.publicKey == pubkey })
    }

    // MARK: - Signing

    public mutating func partialSign(signers: [KeyPair]) throws {
        guard !signers.isEmpty else {
            throw VersionedTransactionError.noSigner
        }

        // unique signers
        let signers = signers.reduce([KeyPair]()) { signers, signer in
            var uniqueSigners = signers
            if !uniqueSigners.contains(where: { $0.publicKey == signer.publicKey }) {
                uniqueSigners.append(signer)
            }
            return uniqueSigners
        }

        // construct message
        let message = try compile()

        try partialSign(message: message, signers: signers)
    }

    private mutating func partialSign(message: Message, signers: [KeyPair]) throws {
        let signData = try message.serialize()

        for signer in signers {
            let data = try NaclSign.signDetached(message: signData, secretKey: signer.secretKey)
            try _addSignature(Signature(signature: data, publicKey: signer.publicKey))
        }
    }

    private mutating func _addSignature(_ signature: Signature) throws {
        guard let data = signature.signature,
              data.count == 64,
              let index = signatures.firstIndex(where: { $0.publicKey == signature.publicKey })
        else {
            throw VersionedTransactionError.invalidSigner(signature.publicKey.base58EncodedString)
        }

        signatures[index] = signature
    }

    // MARK: - Compiling

    private mutating func compile() throws -> Message {
        let message = try compileMessage()
        let signedKeys = message.accountKeys[0 ..< Int(message.header.numRequiredSignatures)]

        if signatures.count == signedKeys.count {
            var isValid = true
            for (index, signature) in signatures.enumerated() {
                if signedKeys[index] != signature.publicKey {
                    isValid = false
                    break
                }
            }
            if isValid {
                return message
            }
        }

        signatures = signedKeys.map { Signature(signature: nil, publicKey: $0) }
        return message
    }

    public func compileMessage() throws -> Message {
        // verify instructions
        guard !instructions.isEmpty else {
            throw VersionedTransactionError.noInstructionProvided
        }
        guard let feePayer = feePayer else {
            throw VersionedTransactionError.feePayerNotFound
        }
        guard let recentBlockhash = recentBlockhash else {
            throw VersionedTransactionError.recentBlockhashNotFound
        }

        // programIds & accountMetas
        var programIds = [PublicKey]()
        var accountMetas = [AccountMeta]()

        for instruction in instructions {
            accountMetas.append(contentsOf: instruction.keys)
            if !programIds.contains(instruction.programId) {
                programIds.append(instruction.programId)
            }
        }

        // Append programID account metas
        for programId in programIds {
            accountMetas.append(
                .init(publicKey: programId, isSigner: false, isWritable: false)
            )
        }

        // sort accountMetas, first by signer, then by writable
        accountMetas.sort { x, y -> Bool in
            if x.isSigner != y.isSigner { return x.isSigner }
            if x.isWritable != y.isWritable { return x.isWritable }
            return false
        }

        // filterOut duplicate account metas, keeps writable one
        accountMetas = accountMetas.reduce([AccountMeta]()) { result, accountMeta in
            var uniqueMetas = result
            if let index = uniqueMetas.firstIndex(where: { $0.publicKey == accountMeta.publicKey }) {
                // if accountMeta exists
                uniqueMetas[index].isWritable = uniqueMetas[index].isWritable || accountMeta.isWritable
            } else {
                uniqueMetas.append(accountMeta)
            }
            return uniqueMetas
        }

        // Cull duplicate account metas
        var uniqueMetas: [AccountMeta] = []
        accountMetas.forEach { accountMeta in
            let pubkey = accountMeta.publicKey.base58EncodedString
            let uniqueIndex = uniqueMetas.firstIndex { x in x.publicKey.base58EncodedString == pubkey }
            if let uniqueIndex = uniqueIndex {
                uniqueMetas[uniqueIndex].isWritable = uniqueMetas[uniqueIndex].isWritable || accountMeta.isWritable
            } else {
                uniqueMetas.append(accountMeta)
            }
        }

        // move fee payer to front
        let feePayerIndex = uniqueMetas.firstIndex { x in x.publicKey == feePayer }
        if let feePayerIndex = feePayerIndex {
            var payerMeta = uniqueMetas.remove(at: feePayerIndex)
            payerMeta.isSigner = true
            payerMeta.isWritable = true
            uniqueMetas.insert(payerMeta, at: 0)
        } else {
            uniqueMetas.insert(
                AccountMeta(
                    publicKey: feePayer,
                    isSigner: true,
                    isWritable: true
                ),
                at: 0
            )
        }

        // accountMetas.removeAll(where: { $0.publicKey == feePayer })
        // accountMetas.insert(
        //    AccountMeta(publicKey: feePayer, isSigner: true, isWritable: true),
        //    at: 0
        // )

        // verify signers
        for signature in signatures {
            if let index = try? uniqueMetas.index(ofElementWithPublicKey: signature.publicKey) {
                if !uniqueMetas[index].isSigner {
                    // TODO: check
                    uniqueMetas[index].isSigner = true
//                        accountMetas[index].isSigner = true
//                        Logger.log(message: "Transaction references a signature that is unnecessary, only the fee payer and instruction signer accounts should sign a transaction. This behavior is deprecated and will throw an error in the next major version release.", event: .warning)
                    print("WARN: Transaction references a signature that is unnecessary")
//                        throw Error.invalidRequest(reason: "Transaction references a signature that is unnecessary")
                }
            } else {
                throw VersionedTransactionError.unknownSigner(signature.publicKey.base58EncodedString)
            }
        }

        // header
        var header = MessageHeader()

        var signedKeys = [AccountMeta]()
        var unsignedKeys = [AccountMeta]()

        uniqueMetas.forEach { accountMeta in
            // signed keys
            if accountMeta.isSigner {
                signedKeys.append(accountMeta)
                header.numRequiredSignatures += 1

                if !accountMeta.isWritable {
                    header.numReadonlySignedAccounts += 1
                }
            }

            // unsigned keys
            else {
                unsignedKeys.append(accountMeta)

                if !accountMeta.isWritable {
                    header.numReadonlyUnsignedAccounts += 1
                }
            }
        }

        accountMetas = signedKeys + unsignedKeys
        let accountKeys = accountMetas.map(\.publicKey)
        let instructions = instructions.compile(accountKeys: accountKeys)
        try instructions.forEach { instruction in
            try instruction.accounts.forEach { keyIndex in
                if keyIndex < 0 { throw VersionedTransactionError.unknown }
            }
        }

        return Message(
            header: header,
            accountKeys: accountKeys,
            recentBlockhash: recentBlockhash,
            instructions: instructions
        )
    }

    // MARK: - Verifying

    private mutating func _verifySignatures(
        serializedMessage: Data,
        requiredAllSignatures: Bool
    ) -> Bool {
        for signature in signatures {
            if signature.signature == nil {
                if requiredAllSignatures {
                    return false
                }
            } else {
                if (try? NaclSign.signDetachedVerify(
                    message: serializedMessage,
                    sig: signature.signature!,
                    publicKey: signature.publicKey.data
                )) != true {
                    return false
                }
            }
        }
        return true
    }

    // MARK: - Serializing

    private mutating func _serialize(serializedMessage: Data) -> Data {
        // signature length
        let signaturesLength = signatures.count

        // signature data
        let signaturesData = signatures.reduce(Data()) { result, signature in
            var data = result
            if let signature = signature.signature {
                data.append(signature)
            } else {
                data.append(Constants.defaultSignature)
            }
            return data
        }

        let encodedSignatureLength = Data.encodeLength(signaturesLength)

        // transaction length
        var data = Data(capacity: encodedSignatureLength.count + signaturesData.count + serializedMessage.count)
        data.append(encodedSignatureLength)
        data.append(signaturesData)
        data.append(serializedMessage)
        return data
    }

    public static func from(data: Data) throws -> Transaction {
        var data = data
        var signatures: [String] = []
        let signatureCount = data.decodeLength()

        for _ in stride(from: 0, through: signatureCount - 1, by: 1) {
            let signatureData = data.prefix(Constants.signatureLength)
            data = data.dropFirst(Constants.signatureLength)
            signatures.append(Base58.encode(signatureData))
        }

        print(data.base64EncodedString())
        return try populate(Message.from(data: data), signatures)
    }

    static func populate(_ message: Message, _ signatures: [String]) -> Transaction {
        var transaction = Transaction()

        transaction.recentBlockhash = message.recentBlockhash
        if message.header.numRequiredSignatures > 0 {
            transaction.feePayer = message.accountKeys[0]
        }
        signatures.enumerated().forEach { index, signature in
            let sigPubkeyPair = Signature(
                signature: signature == Base58
                    .encode(Constants.defaultSignature) ? nil : Data(Base58.decode(signature)),
                publicKey: message.accountKeys[index]
            )
            transaction.signatures.append(sigPubkeyPair)
        }

        message.instructions.forEach { instruction in
            let keys: [AccountMeta] = instruction.accounts.map { account in
                let pubkey = message.accountKeys[account]
                return AccountMeta(
                    publicKey: pubkey,
                    isSigner: transaction.signatures.contains { keyObj in keyObj.publicKey == pubkey } || message
                        .isAccountSigner(index: account),
                    isWritable: message.isAccountWritable(index: account)
                )
            }

            transaction.instructions.append(
                TransactionInstruction(
                    keys: keys,
                    programId: message.accountKeys[instruction.programIdIndexValue],
                    data: instruction.data
                )
            )
        }

        return transaction
    }
}

public struct Signature: Encodable, Equatable {
    public var signature: Data?
    public var publicKey: PublicKey

    enum CodingKeys: String, CodingKey {
        case signature, publicKey
    }

    public init(signature: Data?, publicKey: PublicKey) {
        self.signature = signature
        self.publicKey = publicKey
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Base58.encode(signature?.bytes ?? []), forKey: .signature)
        try container.encode(publicKey.base58EncodedString, forKey: .publicKey)
    }
}

private extension Array where Element == AccountMeta {
    func index(ofElementWithPublicKey publicKey: PublicKey) throws -> Int {
        guard let index = firstIndex(where: { $0.publicKey == publicKey })
        else { throw VersionedTransactionError.unknown }
        return index
    }
}
