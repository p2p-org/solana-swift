import Foundation

public enum VersionedMessage: Equatable {
    case legacy(Message)
    case v0(MessageV0)

    static func deserialize(data: Data) throws -> Self {
        guard !data.isEmpty else {
            throw VersionedMessageError.deserializationError("Data is empty")
        }
        let prefix: UInt8 = data.first!
        let maskedPrefix = prefix & Constants.versionPrefixMask

        if maskedPrefix == prefix {
            return try .legacy(.from(data: data))
        } else {
            return try .v0(.deserialize(serializedMessage: data))
        }
    }

    public var value: IMessage {
        switch self {
        case let .legacy(message): return message
        case let .v0(message): return message
        }
    }

    public mutating func setRecentBlockHash(_ blockHash: BlockHash) {
        switch self {
        case var .legacy(message):
            message.recentBlockhash = blockHash
            self = .legacy(message)
        case var .v0(messageV0):
            messageV0.recentBlockhash = blockHash
            self = .v0(messageV0)
        }
    }
}
