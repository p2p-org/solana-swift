import Foundation

public struct MessageV0: IMessage, Equatable {
    public var version: TransactionVersion { .v0 }

    public var header: MessageHeader
    public var staticAccountKeys: [PublicKey]
    public var recentBlockhash: BlockHash
    public var compiledInstructions: [MessageCompiledInstruction]
    public let addressTableLookups: [MessageAddressTableLookup]

    public init(
        header: MessageHeader,
        staticAccountKeys: [PublicKey],
        recentBlockhash: BlockHash,
        compiledInstructions: [MessageCompiledInstruction],
        addressTableLookups: [MessageAddressTableLookup]
    ) {
        self.header = header
        self.staticAccountKeys = staticAccountKeys
        self.recentBlockhash = recentBlockhash
        self.compiledInstructions = compiledInstructions
        self.addressTableLookups = addressTableLookups
    }

    public var numAccountKeysFromLookups: Int {
        var count = 0
        for lookup in addressTableLookups {
            count += lookup.readonlyIndexes.count + lookup.writableIndexes.count
        }
        return count
    }

    public func getAccountKeys(accountKeysFromLookups: AccountKeysFromLookups) -> MessageAccountKeys {
        .init(
            staticAccountKeys: staticAccountKeys,
            accountKeysFromLookups: accountKeysFromLookups
        )
    }

    public func getAccountKeys(addressLookupTableAccounts: [AddressLookupTableAccount]) throws -> MessageAccountKeys {
        let accountKeysFromLookups = try resolveAddressTableLookups(
            addressLookupTableAccounts: addressLookupTableAccounts
        )

        return .init(
            staticAccountKeys: staticAccountKeys,
            accountKeysFromLookups: accountKeysFromLookups
        )
    }

    public func isAccountSigner(index: Int) -> Bool {
        index < header.numRequiredSignatures
    }

    public func isAccountWritable(index: Int) -> Bool {
        let numSignedAccounts = header.numRequiredSignatures
        let numStaticAccountKeys = staticAccountKeys.count

        if index >= numStaticAccountKeys {
            let lookupAccountKeysIndex = index - numStaticAccountKeys
            let numWritableLookupAccountKeys = addressTableLookups.reduce(0) { count, lookup in
                count + lookup.writableIndexes.count
            }
            return lookupAccountKeysIndex < numWritableLookupAccountKeys
        } else if index >= header.numRequiredSignatures {
            let unsignedAccountIndex = index - numSignedAccounts
            let numUnsignedAccounts = numStaticAccountKeys - numSignedAccounts
            let numWritableUnsignedAccounts = numUnsignedAccounts - header.numReadonlyUnsignedAccounts
            return unsignedAccountIndex < numWritableUnsignedAccounts
        } else {
            let numWritableSignedAccounts = numSignedAccounts - header.numReadonlySignedAccounts
            return index < numWritableSignedAccounts
        }
    }

    public func resolveAddressTableLookups(
        addressLookupTableAccounts: [AddressLookupTableAccount]
    ) throws -> AccountKeysFromLookups {
        var accountKeysFromLookups = AccountKeysFromLookups(readonly: [], writable: [])

        for tableLookup in addressTableLookups {
            let tableAccount = addressLookupTableAccounts.first { account in
                account.key == tableLookup.accountKey
            }

            guard let tableAccount = tableAccount else {
                throw VersionedMessageError
                    .other(
                        "Failed to find address lookup table account for table key \(tableLookup.accountKey.base58EncodedString)"
                    )
            }

            for index in tableLookup.writableIndexes {
                if index < tableAccount.state.addresses.count {
                    accountKeysFromLookups.writable.append(
                        tableAccount.state.addresses[Int(index)]
                    )
                } else {
                    throw VersionedMessageError
                        .other(
                            "Failed to find address for index \(index) in address lookup table \(tableLookup.accountKey.base58EncodedString)"
                        )
                }
            }

            for index in tableLookup.readonlyIndexes {
                if index < tableAccount.state.addresses.count {
                    accountKeysFromLookups.readonly.append(
                        tableAccount.state.addresses[Int(index)]
                    )
                } else {
                    throw VersionedMessageError
                        .other(
                            "Failed to find address for index \(index) in address lookup table \(tableLookup.accountKey.base58EncodedString)"
                        )
                }
            }
        }

        return accountKeysFromLookups
    }

    public func serialize() throws -> Data {
        let messageVersion0Prefix: UInt8 = 1 << 7

        var message = Data()

        // Header
        message.append(Data(messageVersion0Prefix.bytes))
        message.append(serializeHeader())

        // Accounts
        message.append(Data.encodeLength(staticAccountKeys.count))
        message.append(staticAccountKeys.map(\.data).reduce(Data(), +))

        // Blockhash
        message.append(serializeRecentBlockhash())

        // Instructions
        message.append(Data.encodeLength(compiledInstructions.count))
        message.append(serializeInstructions())
//        message.append(Data.encodeLength(0))
//        message.append(serializeInstructions())

        // Table look uolana
        message.append(Data.encodeLength(addressTableLookups.count))
        try message.append(serializeAddressTableLookups())

        return message
    }

    internal func serializeHeader() -> Data {
        Data(header.bytes)
    }

    internal func serializeInstructions() -> Data {
//        var serializedInstructions: Data = .init()
//
//        for instruction in compiledInstructions {
//            let encodedAccountKeyIndexesLength = Data.encodeLength(instruction.accountKeyIndexes.count)
//            let encodedDataLength = Data.encodeLength(instruction.data.count)
//
//            serializedInstructions.append(Data(instruction.programIdIndex.bytes))
//            serializedInstructions.append(encodedAccountKeyIndexesLength)
//            serializedInstructions.append(Data(Array(instruction.accountKeyIndexes.reduce([], +))))
//            serializedInstructions.append(encodedDataLength)
//            serializedInstructions.append(Data(instruction.data))
//        }

//        let instructionsLength = Data.encodeLength(compiledInstructions.count)
        Data(compiledInstructions.map(\.serializedData).reduce([], +))
    }

    internal func serializeAddressTableLookups() throws -> Data {
        var serializedAddressTableLookups = Data()

        for lookup in addressTableLookups {
            serializedAddressTableLookups.append(lookup.accountKey.data)

            serializedAddressTableLookups.append(Data.encodeLength(lookup.writableIndexes.count))
            try serializedAddressTableLookups.append(lookup.writableIndexes.rawSerialized())

            serializedAddressTableLookups.append(Data.encodeLength(lookup.readonlyIndexes.count))
            try serializedAddressTableLookups.append(lookup.readonlyIndexes.rawSerialized())
        }

        return serializedAddressTableLookups
    }

    internal func serializeRecentBlockhash() -> Data {
        Data(Base58.decode(recentBlockhash))
    }

    public static func compile(
        payerKey: PublicKey,
        instructions: [TransactionInstruction],
        recentBlockHash: BlockHash,
        addressLookupTableAccounts: [AddressLookupTableAccount]?
    ) throws -> Self {
        var compiledKeys = CompiledKeys.compile(instructions: instructions, payer: payerKey)

        var addressTableLookups: [MessageAddressTableLookup] = []
        var accountKeysFromLookups: AccountKeysFromLookups = .init(readonly: [], writable: [])

        let lookupTableAccounts = addressLookupTableAccounts ?? []

        for lookupTable in lookupTableAccounts {
            if let extractResult = try compiledKeys.extractTableLookup(lookupTable: lookupTable) {
                addressTableLookups.append(extractResult.0)
                accountKeysFromLookups.writable.append(contentsOf: extractResult.1.writable)
                accountKeysFromLookups.readonly.append(contentsOf: extractResult.1.readonly)
            }
        }

        let (header, staticAccountKeys) = compiledKeys.getMessageComponents()
        let accountKeys = MessageAccountKeys(
            staticAccountKeys: staticAccountKeys,
            accountKeysFromLookups: accountKeysFromLookups
        )
        let compiledInstructions = try accountKeys.compileInstructions(instructions: instructions)

        return MessageV0(
            header: header,
            staticAccountKeys: staticAccountKeys,
            recentBlockhash: recentBlockHash,
            compiledInstructions: compiledInstructions,
            addressTableLookups: addressTableLookups
        )
    }

    public static func deserialize(serializedMessage: Data) throws -> Self {
        var byteArray = BinaryReader(bytes: serializedMessage.bytes)

        let prefix: UInt8 = try byteArray.read()
        let maskedPrefix: UInt8 = prefix & Constants.versionPrefixMask
        guard prefix != maskedPrefix else {
            throw VersionedMessageError.expectedVersionedMessageButReceivedLegacyMessage
        }

        let version = maskedPrefix
        guard version == 0 else {
            throw VersionedMessageError.invalidMessageVersion(expectedVersion: 0, receivedVersion: version)
        }

        let header = try MessageHeader(
            numRequiredSignatures: Int(byteArray.read()),
            numReadonlySignedAccounts: Int(byteArray.read()),
            numReadonlyUnsignedAccounts: Int(byteArray.read())
        )

        var staticAccountKeys: [PublicKey] = []
        let staticAccountKeysLength = try byteArray.decodeLength()
        for _ in 0 ..< staticAccountKeysLength {
            let account: [UInt8] = try byteArray.read(count: PublicKey.numberOfBytes)
            try staticAccountKeys.append(PublicKey(string: Base58.encode(account)))
        }

        let recentBlockhash = try Base58.encode(byteArray.read(count: PublicKey.numberOfBytes))

        let instructionCount = try byteArray.decodeLength()
        var compiledInstructions: [MessageCompiledInstruction] = []
        for _ in 0 ..< instructionCount {
            let programIdIndex = try byteArray.read()
            let accountKeyIndexesLength = try byteArray.decodeLength()
            let accountKeyIndexes = try byteArray.read(count: accountKeyIndexesLength)
            let dataLength = try byteArray.decodeLength()
            let data = try byteArray.read(count: dataLength)
            compiledInstructions.append(
                .init(
                    programIdIndex: programIdIndex,
                    accountKeyIndexes: accountKeyIndexes,
                    data: data
                )
            )
        }

        let addressTableLookupsCount = try byteArray.decodeLength()
        var addressTableLookups: [MessageAddressTableLookup] = []
        for _ in 0 ..< addressTableLookupsCount {
            let accountKey = try PublicKey(string: Base58.encode(byteArray.read(count: PublicKey.numberOfBytes)))
            let writableIndexesLength = try byteArray.decodeLength()
            let writableIndexes = try byteArray.read(count: writableIndexesLength)
            let readonlyIndexesLength = try byteArray.decodeLength()
            let readonlyIndexes = try byteArray.read(count: readonlyIndexesLength)
            addressTableLookups.append(
                .init(
                    accountKey: accountKey,
                    writableIndexes: writableIndexes,
                    readonlyIndexes: readonlyIndexes
                )
            )
        }

        return .init(
            header: header,
            staticAccountKeys: staticAccountKeys,
            recentBlockhash: recentBlockhash,
            compiledInstructions: compiledInstructions,
            addressTableLookups: addressTableLookups
        )
    }
}
