import Foundation

struct LookupTableMeta: BufferLayout {
    let typeIndex: UInt32
    let deactivationSlot: UInt64
    let lastExtendedSlot: UInt64
    let lastExtendedStartIndex: UInt8
    let authority: [PublicKey]

    public func serialize(to _: inout Data) throws {
        fatalError()
    }

    public init(from reader: inout BinaryReader) throws {
        typeIndex = try .init(from: &reader)
        deactivationSlot = try .init(from: &reader)
        lastExtendedSlot = try .init(from: &reader)
        lastExtendedStartIndex = try .init(from: &reader)
        _ = try UInt8(from: &reader)
        authority = [try PublicKey(from: &reader)]
    }
}

public struct AddressLookupTableState: Equatable, Codable, BufferLayout {
    let typeIndex: UInt32
    let deactivationSlot: UInt64
    let lastExtendedSlot: UInt64
    let lastExtendedSlotStartIndex: UInt8
    let authority: PublicKey?
    let addresses: [PublicKey]

    public func serialize(to _: inout Data) throws {
        fatalError()
    }

    public init(from reader: inout BinaryReader) throws {
        var readerForAddresses = reader

        typeIndex = try .init(from: &reader)
        deactivationSlot = try .init(from: &reader)
        lastExtendedSlot = try .init(from: &reader)
        lastExtendedSlotStartIndex = try .init(from: &reader)
        _ = try UInt8(from: &reader)
        authority = try PublicKey(bytes: reader.read(count: PublicKey.numberOfBytes))

        try readerForAddresses.read(count: AddressLookupTableAccount.lookUpTableMetaSize)
        var addresses: [PublicKey] = []
        while readerForAddresses.remainBytes > PublicKey.numberOfBytes {
            try addresses.append(PublicKey(bytes: readerForAddresses.read(count: PublicKey.numberOfBytes)))
        }

        self.addresses = addresses
    }
}

public struct AddressLookupTableAccount: Equatable {
    public static let lookUpTableMetaSize = 56

    public let key: PublicKey
    public let state: AddressLookupTableState

    public init(key: PublicKey, state: AddressLookupTableState) {
        self.key = key
        self.state = state
    }

    var isActive: Bool {
        return state.deactivationSlot == UInt64.max
    }

//    // TODO: implement?
//    public func serialize(to writer: inout Data) throws {
//        fatalError()
//    }
//
//    // TODO: Improve
//    public init(from reader: inout BinaryReader) throws {
//        var accountDataReader = reader
//        let meta = try LookupTableMeta(from: &accountDataReader)
//
//        // TODO: Transalte JS code to Swift
//        // const serializedAddressesLen = accountData.length - LOOKUP_TABLE_META_SIZE;
//        // assert(serializedAddressesLen >= 0, 'lookup table is invalid');
//        // assert(serializedAddressesLen % 32 === 0, 'lookup table is invalid');
//
//        let serializedAddressesLen = reader.remainBytes - Self.lookUpTableMetaSize
//        let numSerializedAddresses = serializedAddressesLen / 32
//
//        var addresses: [PublicKey] = []
//        try reader.read(count: Self.lookUpTableMetaSize)
//        for _ in 0 ..< numSerializedAddresses {
//            addresses.append(try PublicKey(bytes: try reader.read(count: PublicKey.numberOfBytes)))
//        }
//
//        return .init(
//            deactivationSlot: meta.deactivationSlot,
//            lastExtendedSlot: meta.lastExtendedSlot,
//            lastExtendedSlotStartIndex: meta.lastExtendedStartIndex,
//            authority: meta.authority.first,
//            addresses: addresses
//        )
//    }
}
