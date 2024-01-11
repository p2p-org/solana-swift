import Foundation

public struct MessageHeader: Decodable, Equatable {
    static let LENGTH = 3

    public internal(set) var numRequiredSignatures: Int = 0
    public internal(set) var numReadonlySignedAccounts: Int = 0
    public internal(set) var numReadonlyUnsignedAccounts: Int = 0

    var bytes: [UInt8] {
        [UInt8(numRequiredSignatures), UInt8(numReadonlySignedAccounts), UInt8(numReadonlyUnsignedAccounts)]
    }
}

public struct MessageCompiledInstruction: Equatable {
    public let programIdIndex: UInt8
    public let accountKeyIndexes: [UInt8]
    public let data: [UInt8]

    public init(programIdIndex: UInt8, accountKeyIndexes: [UInt8], data: [UInt8]) {
        self.programIdIndex = programIdIndex
        self.accountKeyIndexes = accountKeyIndexes
        self.data = data
    }

    var serializedData: Data {
        Data([programIdIndex])
            + Data.encodeLength(accountKeyIndexes.count)
            + Data(accountKeyIndexes)
            + Data.encodeLength(data.count)
            + Data(data)
    }
}
