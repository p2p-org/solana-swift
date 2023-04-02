//
//  File.swift
//
//
//  Created by Giang Long Tran on 14.01.2023.
//

import Foundation

public enum VersionedMessage: Equatable {
    case legacy(Message)
    case v0(MessageV0)

    static func deserialize(data: Data) throws -> Self {
        guard data.count > 0 else { throw SolanaError.assertionFailed("Data is empty") }
        let prefix: UInt8 = data.first!
        let maskedPrefix = prefix & Constants.versionPrefixMask
        
        if maskedPrefix == prefix {
            return .legacy(try .from(data: data))
        } else {
            return .v0(try .deserialize(serializedMessage: data))
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
        case .legacy(var message):
            message.recentBlockhash = blockHash
            self = .legacy(message)
        case .v0(var messageV0):
            messageV0.recentBlockhash = blockHash
            self = .v0(messageV0)
        }
    }
}
