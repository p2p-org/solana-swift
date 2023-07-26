import Foundation

/// Blockhash as Base58 string.
public typealias BlockHash = String

/// Lecagy message
public struct Message: IMessage, Equatable {
    public var version: TransactionVersion { .legacy }

    // MARK: - Constants

    private static let RECENT_BLOCK_HASH_LENGTH = 32

    // MARK: - Properties

    public internal(set) var header: MessageHeader
    public internal(set) var accountKeys: [PublicKey]
    public internal(set) var recentBlockhash: BlockHash
    public internal(set) var instructions: [CompiledInstruction]
    public var staticAccountKeys: [PublicKey] { accountKeys }

    init(header: MessageHeader, accountKeys: [PublicKey], recentBlockhash: BlockHash,
         instructions: [CompiledInstruction])
    {
        self.header = header
        self.accountKeys = accountKeys
        self.recentBlockhash = recentBlockhash
        self.instructions = instructions
    }

    public func serialize() throws -> Data {
        // Header
        let header = encodeHeader()

        // Account keys
        let accountKeys = encodeAccountKeys()

        // RecentBlockHash
        let recentBlockhash = encodeRecentBlockhash()

        // Compiled instruction
        let compiledInstruction = try encodeInstructions()

        // Construct data
        //            let bufferSize: Int =
        //                Header.LENGTH // header
        //                + keyCount.count // number of account keys
        //                + Int(accountKeys.count) * PublicKey.LENGTH // account keys
        //                + RECENT_BLOCK_HASH_LENGTH // recent block hash
        //                + instructionsLength.count
        //                + compiledInstructionsLength

        var data = Data( /* capacity: bufferSize */ )

        // Append data
        data.append(header)
        data.append(accountKeys)
        data.append(recentBlockhash)
        data.append(compiledInstruction)

        return data
    }

    static func from(data: Data) throws -> Message {
        var data = data

        let numRequiredSignatures = data.removeFirst()
        let numReadonlySignedAccounts = data.removeFirst()
        let numReadonlyUnsignedAccounts = data.removeFirst()

        let accountCount = data.decodeLength()
        var accountKeys: [PublicKey] = []
        for _ in 0 ..< accountCount {
            let account = data.prefix(PublicKey.numberOfBytes)
            data = data.dropFirst(PublicKey.numberOfBytes)
            try accountKeys.append(PublicKey(string: Base58.encode(account.bytes)))
        }

        let recentBlockhash = data.prefix(PublicKey.numberOfBytes)
        data = data.dropFirst(PublicKey.numberOfBytes)

        let instructionCount = data.decodeLength()
        var instructions: [CompiledInstruction] = []
        for _ in 0 ..< instructionCount {
            let programIdIndex = data.removeFirst()
            let accountCount = data.decodeLength()
            let accounts = data.prefix(accountCount)
            data = data.dropFirst(accountCount)
            let dataLength = data.decodeLength()
            let dataSlice = data.prefix(dataLength)
            data = data.dropFirst(dataLength)
            instructions.append(
                CompiledInstruction(
                    programIdIndex: programIdIndex,
                    keyIndicesCount: Data.encodeLength(accountCount).bytes,
                    keyIndices: accounts.bytes,
                    dataLength: Data.encodeLength(dataLength).bytes,
                    data: dataSlice.bytes
                )
            )
        }

        return Message(
            header: MessageHeader(numRequiredSignatures: Int(numRequiredSignatures),
                                  numReadonlySignedAccounts: Int(numReadonlySignedAccounts),
                                  numReadonlyUnsignedAccounts: Int(numReadonlyUnsignedAccounts)),
            accountKeys: accountKeys,
            recentBlockhash: Base58.encode(recentBlockhash.bytes),
            instructions: instructions
        )
    }

    public func isAccountWritable(index: Int) -> Bool {
        (index < header.numRequiredSignatures - header.numReadonlySignedAccounts)
            ||
            (index >= header.numRequiredSignatures && index < accountKeys.count - header
                .numReadonlyUnsignedAccounts)
    }

    public func isAccountSigner(index: Int) -> Bool {
        index < header.numRequiredSignatures
    }

    private func encodeHeader() -> Data {
        Data(header.bytes)
    }

    private func encodeAccountKeys() -> Data {
        // length
        let keyCount = encodeLength(accountKeys.count)

        // construct data
        var data = Data(capacity: keyCount.count + accountKeys.count * PublicKey.numberOfBytes)

        // append data
        data.append(keyCount)
        for key in accountKeys {
            data.append(key.data)
        }
        return data
    }

    private func encodeRecentBlockhash() -> Data {
        Data(Base58.decode(recentBlockhash))
    }

    private func encodeInstructions() throws -> Data {
        let instructionsLength = Data.encodeLength(instructions.count)
        return instructionsLength + instructions.reduce(Data()) { $0 + $1.serializedData }
    }

    private func encodeLength(_ length: Int) -> Data {
        Data.encodeLength(length)
    }
}
